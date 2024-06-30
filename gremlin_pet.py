import discord
from discord.ext import commands, tasks
import random
import json
import os
from io import BytesIO
from PIL import Image, ImageDraw, ImageFont
import pytz
from datetime import datetime, timedelta
import asyncio
import logging
from typing import Dict, Optional, Any, Union
import aiofiles

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger('gremlin_bot')

# Constants
MAX_STAT_VALUE = 100
MIN_STAT_VALUE = 0

# Configuration loading and validation
def load_config() -> Dict[str, Any]:
    """
    Load and validate the configuration file.
    
    Returns:
        Dict[str, Any]: Validated configuration dictionary
    
    Raises:
        FileNotFoundError: If the config file is not found
        json.JSONDecodeError: If the config file is not valid JSON
        ValueError: If the config file is missing required fields or has invalid values
    """
    base_dir = os.path.dirname(os.path.abspath(__file__))
    config_path = os.path.join(base_dir, 'config.json')
    
    try:
        with open(config_path, 'r') as config_file:
            config = json.load(config_file)
    except FileNotFoundError:
        logger.error(f"Config file not found at {config_path}")
        raise
    except json.JSONDecodeError:
        logger.error(f"Invalid JSON in config file at {config_path}")
        raise
    
    # Validate required fields
    required_fields = ['bot_token', 'guild_id', 'channel_id', 'file_paths', 'time_settings']
    for field in required_fields:
        if field not in config:
            logger.error(f"Missing required field '{field}' in config file")
            raise ValueError(f"Missing required field '{field}' in config file")
    
    # Set the base_dir in the config
    config['file_paths']['base_dir'] = base_dir
    
    # Update file paths to be absolute
    for key in ['gremlin_data_file', 'font_path']:
        config['file_paths'][key] = os.path.join(base_dir, config['file_paths'][key])
    
    for key in ['room_backgrounds', 'normal_gremlin_images', 'transformed_gremlin_images']:
        config[key] = [os.path.join(base_dir, path) for path in config[key]]
    
    for prank in config['pranks']:
        prank['image'] = os.path.join(base_dir, prank['image'])
    
    # Validate timezone
    if 'timezone' not in config['time_settings']:
        logger.warning("Timezone not specified in config. Using default 'US/Central'")
        config['time_settings']['timezone'] = 'US/Central'
    try:
        pytz.timezone(config['time_settings']['timezone'])
    except pytz.exceptions.UnknownTimeZoneError:
        logger.error(f"Invalid timezone '{config['time_settings']['timezone']}' in config file")
        raise ValueError(f"Invalid timezone '{config['time_settings']['timezone']}' in config file")
    
    return config

CONFIG = load_config()

intents = discord.Intents.default()
intents.message_content = True

bot = commands.Bot(command_prefix='!', intents=intents)

class Gremlin:
    """
    Represents a Gremlin pet with various attributes and methods to interact with it.
    """
    def __init__(self, name: str, image: str, room_background: str):
        self.name: str = name
        self.image: str = image
        self.room_background: str = room_background
        self.hunger: int = self.happiness: int = self.energy: int = 50
        self.transformed: bool = False
        self.transformation_time: Optional[datetime] = None
        self.last_revert_attempt: Optional[datetime] = None

    def to_dict(self) -> Dict[str, Any]:
        """Convert Gremlin object to dictionary for serialization."""
        return {
            "name": self.name,
            "image": self.image,
            "room_background": self.room_background,
            "hunger": self.hunger,
            "happiness": self.happiness,
            "energy": self.energy,
            "transformed": self.transformed,
            "transformation_time": self.transformation_time.isoformat() if self.transformation_time else None,
            "last_revert_attempt": self.last_revert_attempt.isoformat() if self.last_revert_attempt else None
        }

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'Gremlin':
        """Create a Gremlin object from a dictionary."""
        gremlin = cls(data["name"], data["image"], data["room_background"])
        gremlin.hunger = data["hunger"]
        gremlin.happiness = data["happiness"]
        gremlin.energy = data["energy"]
        gremlin.transformed = data["transformed"]
        gremlin.transformation_time = datetime.fromisoformat(data["transformation_time"]) if data["transformation_time"] else None
        gremlin.last_revert_attempt = datetime.fromisoformat(data["last_revert_attempt"]) if data["last_revert_attempt"] else None
        return gremlin

    def feed(self) -> None:
        """Feed the Gremlin, decreasing hunger and increasing happiness."""
        self.hunger = max(MIN_STAT_VALUE, self.hunger - CONFIG['game_balance']['feed_hunger_decrease'])
        self.happiness = min(MAX_STAT_VALUE, self.happiness + CONFIG['game_balance']['feed_happiness_increase'])

    def play(self) -> None:
        """Play with the Gremlin, increasing happiness and decreasing energy."""
        self.happiness = min(MAX_STAT_VALUE, self.happiness + CONFIG['game_balance']['play_happiness_increase'])
        self.energy = max(MIN_STAT_VALUE, self.energy - CONFIG['game_balance']['play_energy_decrease'])

    def sleep(self) -> None:
        """Let the Gremlin sleep, increasing energy and slightly increasing hunger."""
        self.energy = min(MAX_STAT_VALUE, self.energy + CONFIG['game_balance']['sleep_energy_increase'])
        self.hunger = min(MAX_STAT_VALUE, self.hunger + CONFIG['game_balance']['sleep_hunger_increase'])

    def update(self) -> None:
        """Update the Gremlin's stats over time."""
        self.hunger = min(MAX_STAT_VALUE, self.hunger + CONFIG['game_balance']['hunger_increase_rate'])
        self.happiness = max(MIN_STAT_VALUE, self.happiness - CONFIG['game_balance']['happiness_decrease_rate'])
        self.energy = max(MIN_STAT_VALUE, self.energy - CONFIG['game_balance']['energy_decrease_rate'])

    def transform(self) -> None:
        """Transform the Gremlin."""
        self.transformed = True
        index = CONFIG['normal_gremlin_images'].index(self.image) if self.image in CONFIG['normal_gremlin_images'] else -1
        self.image = CONFIG['transformed_gremlin_images'][index] if index != -1 else self.image
        self.transformation_time = datetime.now(pytz.timezone(CONFIG['time_settings']['timezone']))

    def revert(self) -> bool:
        """
        Attempt to revert the Gremlin to its normal form.
        
        Returns:
            bool: True if the revert was successful, False otherwise.
        """
        if random.random() < CONFIG['probability_settings']['revert_success_chance']:
            self.transformed = False
            self.image = random.choice(CONFIG['normal_gremlin_images'])
            self.transformation_time = None
            return True
        return False

user_gremlins: Dict[int, Gremlin] = {}

async def load_gremlin_data() -> None:
    """Load Gremlin data from file."""
    global user_gremlins
    try:
        async with asyncio.Lock():
            if os.path.exists(CONFIG['file_paths']['gremlin_data_file']):
                async with aiofiles.open(CONFIG['file_paths']['gremlin_data_file'], "r") as f:
                    data = await f.read()
                    user_gremlins = {int(k): Gremlin.from_dict(v) for k, v in json.loads(data).items()}
        logger.info("Gremlin data loaded successfully")
    except Exception as e:
        logger.error(f"Error loading gremlin data: {e}")

async def save_gremlin_data() -> None:
    """Save Gremlin data to file."""
    try:
        async with asyncio.Lock():
            async with aiofiles.open(CONFIG['file_paths']['gremlin_data_file'], "w") as f:
                await f.write(json.dumps({str(k): v.to_dict() for k, v in user_gremlins.items()}))
        logger.info("Gremlin data saved successfully")
    except Exception as e:
        logger.error(f"Error saving gremlin data: {e}")

@bot.event
async def on_ready() -> None:
    """Event handler for when the bot is ready."""
    logger.info(f"{bot.user} has connected to Discord!")
    await load_gremlin_data()
    update_gremlins.start()

class GremlinCog(commands.Cog):
    """Cog containing Gremlin-related commands."""

    def __init__(self, bot):
        self.bot = bot

    @commands.command(name='adopt', aliases=['get'])
    @commands.cooldown(1, CONFIG['command_cooldowns']['adopt'], commands.BucketType.user)
    async def adopt(self, ctx: commands.Context, gremlin_name: str) -> None:
        """
        Adopt a new Gremlin pet.
        
        Usage: !adopt <gremlin_name>
        """
        user_id = ctx.author.id
        if user_id in user_gremlins:
            await ctx.send("You already have a Gremlin! You can't adopt another one.")
        else:
            gremlin_image = random.choice(CONFIG['normal_gremlin_images'])
            room_background = random.choice(CONFIG['room_backgrounds'])
            user_gremlins[user_id] = Gremlin(gremlin_name, gremlin_image, room_background)
            await ctx.send(f"Congratulations! You've adopted {gremlin_name} the Gremlin!")
            await send_gremlin_status(ctx, user_id)
            await save_gremlin_data()

    @commands.command(name='feed')
    @commands.cooldown(1, CONFIG['command_cooldowns']['feed'], commands.BucketType.user)
    async def feed(self, ctx: commands.Context) -> None:
        """
        Feed your Gremlin pet.
        
        Usage: !feed
        """
        user_id = ctx.author.id
        if user_id not in user_gremlins:
            await ctx.send("You don't have a Gremlin yet. Use !adopt to get one!")
            return

        gremlin = user_gremlins[user_id]
        current_time = datetime.now(pytz.timezone(CONFIG['time_settings']['timezone']))
        
        if 0 <= current_time.hour < 6:
            view = FeedConfirmation()
            await ctx.send("Feeding your Gremlin after midnight is risky! Are you sure you want to do this?", view=view)
            
            await view.wait()
            
            if view.value is None:
                await ctx.send("You didn't respond in time. Feeding cancelled.")
                return
            elif not view.value:
                await ctx.send("Wise choice. Your Gremlin remains unfed, but safe from transformation.")
                return
        
        if 0 <= current_time.hour < 6:
            if not gremlin.transformed:
                gremlin.transform()
                await ctx.send(f"Oh no! You fed {gremlin.name} after midnight! They've transformed into a mischievous creature!")
                
                if random.random() < CONFIG['probability_settings']['transformation_prank_chance']:
                    await gremlin_prank(ctx, gremlin)
            else:
                gremlin.transformation_time = current_time
                await ctx.send(f"{gremlin.name} is already transformed, but feeding them has reset their 24-hour transformation period!")
        else:
            old_hunger = gremlin.hunger
            gremlin.feed()
            hunger_decrease = old_hunger - gremlin.hunger
            await ctx.send(f"You fed {gremlin.name}. Their hunger decreased by {hunger_decrease} points and their happiness increased!")
        
        await send_gremlin_status(ctx, user_id)
        await save_gremlin_data()

    @commands.command(name='status', aliases=['check'])
    @commands.cooldown(1, CONFIG['command_cooldowns']['status'], commands.BucketType.user)
    async def status(self, ctx: commands.Context) -> None:
        """
        Check the status of your Gremlin pet.
        
        Usage: !status
        """
        user_id = ctx.author.id
        if user_id in user_gremlins:
            await send_gremlin_status(ctx, user_id)
        else:
            await ctx.send("You don't have a Gremlin yet. Use !adopt to get one!")

    @commands.command(name='play')
    @commands.cooldown(1, CONFIG['command_cooldowns']['play'], commands.BucketType.user)
    async def play(self, ctx: commands.Context) -> None:
        """
        Play with your Gremlin pet.
        
        Usage: !play
        """
        user_id = ctx.author.id
        if user_id in user_gremlins:
            gremlin = user_gremlins[user_id]
            old_happiness = gremlin.happiness
            old_energy = gremlin.energy
            gremlin.play()
            happiness_increase = gremlin.happiness - old_happiness
            energy_decrease = old_energy - gremlin.energy
            await ctx.send(f"You played with {gremlin.name}. Their happiness increased by {happiness_increase} points and their energy decreased by {energy_decrease} points!")
            await send_gremlin_status(ctx, user_id)
            await save_gremlin_data()
        else:
            await ctx.send("You don't have a Gremlin yet. Use !adopt to get one!")

    @commands.command(name='sleep', aliases=['rest'])
    @commands.cooldown(1, CONFIG['command_cooldowns']['sleep'], commands.BucketType.user)
    async def sleep(self, ctx: commands.Context) -> None:
        """
        Let your Gremlin pet sleep.
        
        Usage: !sleep
        """
        user_id = ctx.author.id
        if user_id in user_gremlins:
            gremlin = user_gremlins[user_id]
            old_energy = gremlin.energy
            old_hunger = gremlin.hunger
            gremlin.sleep()
            energy_increase = gremlin.energy - old_energy
            hunger_increase = gremlin.hunger - old_hunger
            await ctx.send(f"{gremlin.name} took a nap. Their energy increased by {energy_increase} points and their hunger increased by {hunger_increase} points!")
            await send_gremlin_status(ctx, user_id)
            await save_gremlin_data()
        else:
            await ctx.send("You don't have a Gremlin yet. Use !adopt to get one!")

    @commands.command(name='revert')
    @commands.cooldown(1, CONFIG['command_cooldowns']['revert'], commands.BucketType.user)
    async def revert(self, ctx: commands.Context) -> None:
        """
        Attempt to revert your transformed Gremlin.
        
        Usage: !revert
        """
        user_id = ctx.author.id
        if user_id not in user_gremlins:
            await ctx.send("You don't have a Gremlin yet. Use !adopt to get one!")
            return

        gremlin = user_gremlins[user_id]
        current_time = datetime.now(pytz.timezone(CONFIG['time_settings']['timezone']))
        
        if not gremlin.transformed:
            await ctx.send(f"{gremlin.name} is not transformed. No need to revert!")
            return
        
        if gremlin.transformation_time is None or (current_time - gremlin.transformation_time) < timedelta(hours=CONFIG['time_settings']['transformation_duration']):
            time_left = timedelta(hours=CONFIG['time_settings']['transformation_duration']) - (current_time - gremlin.transformation_time)
            await ctx.send(f"{gremlin.name} hasn't been transformed long enough to attempt reverting. Please wait {time_left.seconds // 3600} hours and {(time_left.seconds // 60) % 60} minutes before trying again.")
            return
        
        if gremlin.revert():
            await ctx.send(f"Success! {gremlin.name} has been reverted to their normal form!")
        else:
            await ctx.send(f"The revert attempt failed. {gremlin.name} is still in their transformed state. You can try again in 24 hours.")
        
        await save_gremlin_data()
        await send_gremlin_status(ctx, user_id)

    @commands.Cog.listener()
    async def on_command_error(self, ctx: commands.Context, error: commands.CommandError) -> None:
        """Handle command errors."""
        if isinstance(error, commands.CommandOnCooldown):
            await ctx.send(f"This command is on cooldown. Please try again in {error.retry_after:.2f} seconds.")
        elif isinstance(error, commands.CommandNotFound):
            await ctx.send("Unknown command. Use !help to see available commands.")
        elif isinstance(error, commands.MissingRequiredArgument):
            await ctx.send(f"Missing required argument: {error.param.name}. Use !help {ctx.command.name} for proper usage.")
        else:
            logger.error(f"An error occurred: {error}")
            await ctx.send("An error occurred while processing the command. Please try again later.")

@tasks.loop(minutes=CONFIG['time_settings']['gremlin_update_interval'])
async def update_gremlins() -> None:
    """Update all Gremlins' stats periodically."""
    for user_id, gremlin in user_gremlins.items():
        gremlin.update()

        if gremlin.transformed and random.random() < CONFIG['probability_settings']['prank_chance']:
            guild = bot.get_guild(CONFIG['guild_id'])
            if guild:
                channel = guild.get_channel(CONFIG['channel_id'])
                if channel:
                    ctx = await bot.get_context(await channel.send("Prank time!"))
                    await gremlin_prank(ctx, gremlin)

    await save_gremlin_data()

async def send_gremlin_status(ctx: commands.Context, user_id: int) -> None:
    """Send the status of a Gremlin as an embed with an image."""
    gremlin = user_gremlins[user_id]
    status_image = await create_status_image(gremlin)
    
    with BytesIO() as image_binary:
        status_image.save(image_binary, 'PNG')
        image_binary.seek(0)
        
        file = discord.File(fp=image_binary, filename='gremlin_status.png')
        
        embed = discord.Embed(title=f"{gremlin.name}'s Status", color=0x00ff00)
        embed.add_field(name="Hunger", value=f"{gremlin.hunger}/{MAX_STAT_VALUE}", inline=True)
        embed.add_field(name="Happiness", value=f"{gremlin.happiness}/{MAX_STAT_VALUE}", inline=True)
        embed.add_field(name="Energy", value=f"{gremlin.energy}/{MAX_STAT_VALUE}", inline=True)
        
        if gremlin.transformed:
            time_transformed = datetime.now(pytz.timezone(CONFIG['time_settings']['timezone'])) - gremlin.transformation_time
            embed.add_field(name="Transformed", value=f"Yes, for {time_transformed.days} days and {time_transformed.seconds // 3600} hours", inline=False)
        else:
            embed.add_field(name="Transformed", value="No", inline=False)
        
        current_time = datetime.now(pytz.timezone(CONFIG['time_settings']['timezone']))
        embed.description = f"GGT (Gremlin Greenwich Time): {current_time.strftime('%I:%M %p')}"
        
        embed.set_image(url="attachment://gremlin_status.png")
        
        await ctx.send(file=file, embed=embed)

async def create_status_image(gremlin: Gremlin) -> Image.Image:
    """Create a status image for a Gremlin."""
    loop = asyncio.get_event_loop()
    return await loop.run_in_executor(None, _create_status_image_sync, gremlin)

def _create_status_image_sync(gremlin: Gremlin) -> Image.Image:
    """Synchronous function to create a status image for a Gremlin."""
    background = Image.open(gremlin.room_background)
    gremlin_img = Image.open(gremlin.image).resize((100, 100))  # Adjust size as needed
    
    paste_position = ((background.width - gremlin_img.width) // 2, 
                      background.height - gremlin_img.height - 20)
    
    background.paste(gremlin_img, paste_position, gremlin_img if gremlin_img.mode == 'RGBA' else None)
    
    draw = ImageDraw.Draw(background)
    font = ImageFont.truetype(CONFIG['file_paths']['font_path'], 24)
    name_position = (background.width // 2, 20)
    draw.text(name_position, gremlin.name, font=font, fill="white", anchor="mt")
    
    return background

async def gremlin_prank(ctx: commands.Context, gremlin: Gremlin) -> None:
    """Execute a prank for a transformed Gremlin."""
    if not gremlin.transformed:
        return  # Only transformed gremlins play pranks

    prank = random.choice(CONFIG['pranks'])
    prank_message = f"{gremlin.name} {prank['message']}"
    prank_image = prank['image']

    embed = discord.Embed(title="Gremlin Prank Alert!", description=prank_message, color=0xFF5733)
    embed.set_image(url=f"attachment://{os.path.basename(prank_image)}")

    async with aiofiles.open(prank_image, 'rb') as f:
        file = discord.File(await f.read(), filename=os.path.basename(prank_image))
        await ctx.send(file=file, embed=embed)

class FeedConfirmation(discord.ui.View):
    def __init__(self):
        super().__init__()
        self.value = None

    @discord.ui.button(label='Yes', style=discord.ButtonStyle.green)
    async def confirm(self, interaction: discord.Interaction, button: discord.ui.Button):
        self.value = True
        self.stop()

    @discord.ui.button(label='No', style=discord.ButtonStyle.red)
    async def cancel(self, interaction: discord.Interaction, button: discord.ui.Button):
        self.value = False
        self.stop()

@bot.event
async def on_command_error(ctx, error):
    if isinstance(error, commands.CommandNotFound):
        await ctx.send("Unknown command. Use !help to see available commands.")
    elif isinstance(error, commands.CommandOnCooldown):
        await ctx.send(f"This command is on cooldown. Please try again in {error.retry_after:.2f} seconds.")
    else:
        logger.error(f"Unhandled error: {error}")
        await ctx.send("An error occurred while processing the command. Please try again later.")

@bot.command(name='help')
async def help_command(ctx, command_name: Optional[str] = None):
    """
    Display help information for commands.
    
    Usage: !help [command_name]
    """
    if command_name:
        command = bot.get_command(command_name)
        if command:
            embed = discord.Embed(title=f"Help for {command.name}", description=command.help, color=0x00ff00)
            embed.add_field(name="Usage", value=f"`{command.name} {command.signature}`" if command.signature else f"`{command.name}`")
            await ctx.send(embed=embed)
        else:
            await ctx.send(f"No command named '{command_name}' found.")
    else:
        embed = discord.Embed(title="Gremlin Bot Commands", description="Here are the available commands:", color=0x00ff00)
        for command in bot.commands:
            embed.add_field(name=command.name, value=command.help.split('\n')[0], inline=False)
        embed.add_field(name="For more information", value="Use `!help <command_name>` for detailed information on a specific command.", inline=False)
        await ctx.send(embed=embed)

bot.add_cog(GremlinCog(bot))
bot.run(CONFIG['bot_token'])