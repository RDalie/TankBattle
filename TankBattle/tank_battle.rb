require 'gosu'

#1. make sprite classes
# a.Enemies
# b.Bullets
# --> Bullets for enemies (Instance 1)
# --> Bullets for players (Instance 2)
# c.Player
# d.Armor
# e.Score

#2. Behaviour needed:
# a.Enemies
    # 1: enemy and bullets collision
    # 2: follow the player
# b.Bullets
    # 1: Should travel in the direction the player has shot the bullets
    # 2: Should travel in the direction the enemy has shot the bullets
# c.Player
    # 1: Player and enemy collision
    # 2: Player and enemy bullet collision needed
    # 3: Able to shoot bullets
# d.Armor
    # overlap the player picture using ZOrder
# e.Score
    # Score should be displayed on the game screen
    # Increment everytime player kills an enemy

# 3. Enumeration needed:
# a. Level of display of instances (ZOrder)

# 4. Implementation:
# a.Enemies
    # An array needed to keep track of all kinds of enemies
    # Needs to be cleaned as enemies die
# b.Bullets
    # An array needed to keep track of all bullets (separate for enemies' and players')
    # Needs to be cleaned

# --> Bullets for enemies (Instance 1)
# --> Bullets for players (Instance 2)
# c.Player
# d.Armor
# e.Score
    # Array needed to keep track of player's score



# Constants
SCREEN_WIDTH, SCREEN_HEIGHT = 1200, 600
FRICTION = 0.8
ROTATION_SPEED = 6
ACCELERATION = 0.9
#----------------------------------------ENUMERATIONS---------------------------------------
    # decides overlapping
    module ZOrder
        BACKGROUND, MIDDLE, TOP = *0..2
    end


# ----------------------------------------CLASSES-----------------------------------------
# PLAYER CLASS--------------------------------------------------------------------------
    class Player

        attr_accessor :x, :y, :angle, :radius, :image, :velocity_x, :velocity_y
        def initialize()
            @x = SCREEN_WIDTH/2
            @y = SCREEN_HEIGHT/2
            @angle = 0
            @image = Gosu::Image.new('Sprites/images/soldier1.png')
            @velocity_x = 0
            @velocity_y = 0
            @radius = 40
        end

    end



# ----------------------------------------FUNCTIONS-----------------------------------------

#PLAYER FUNCTIONS-----------------------------------------------------------------------
# moves the player
def player_move(player)

    # CHANGE THE PLAYER'S POSITION
    player.x += player.velocity_x 
    player.y += player.velocity_y

    # CREATES SLOWING DOWN EFFECT
    player.velocity_x *= FRICTION
    player.velocity_y *= FRICTION

    # Prevent the tank from going out the window
    # WINDOW RIGHT
    if player.x > SCREEN_WIDTH - player.radius
        player.velocity_x = 0
        player.x = SCREEN_WIDTH - player.radius
    end

    # WINDOW LEFT
    if player.x < player.radius 
        player.velocity_x = 0
        player.x = player.radius
    end

    # WINDOW BOTTOM
    if player.y > SCREEN_HEIGHT - player.radius
        player.velocity_y = 0
        player.y = SCREEN_HEIGHT - player.radius
    end

    # WINDOW TOP
    if player.y < player.radius
        player.velocity_y = 0
        player.y = player.radius
    end

end

def player_accelerate(player)
    # Using the offset_x and offset_y method to accelerate the tank in the direction it is moving
    player.velocity_x += Gosu.offset_x(player.angle, ACCELERATION)
    player.velocity_y += Gosu.offset_y(player.angle, ACCELERATION)
end

# rotates the player right
def player_turn_right(player)
    player.angle += ROTATION_SPEED
end

# rotates the player left
def player_turn_left(player)
    player.angle -= ROTATION_SPEED
end

# MAIN CLASS--------------------------------------------------------------------------------
class TankBattle < Gosu::Window


    def initialize
        # preparing the game window
        super(SCREEN_WIDTH, SCREEN_HEIGHT)
        self.caption = 'Tank Battle'

        @player = Player.new()
        
        # Arrays to keep track of sprites
        @enemies = []
        @bullets = []     
    end

    def update()
        # Rotating the tank on button press
        player_turn_right(@player) if button_down?(Gosu::KB_RIGHT)
        player_turn_left(@player) if button_down?(Gosu::KB_LEFT)

        # moving the tank forward
        player_accelerate(@player) if button_down?(Gosu::KB_UP)
        player_move(@player)
    end

    def draw()
        draw_rect(0,0,SCREEN_WIDTH,SCREEN_HEIGHT,Gosu::Color.argb(0xff_4cd137),ZOrder::BACKGROUND, mode = :default)
        @player.image.draw_rot(@player.x, @player.y, 1, @player.angle)
    end

end

window = TankBattle.new()
window.show()