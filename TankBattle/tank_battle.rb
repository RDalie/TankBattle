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

# NOTE: PLAYER MOVE AND BULLET MOVE CAN BE MERGED TOGETHER


# Constants
SCREEN_WIDTH, SCREEN_HEIGHT = 1200, 600
FRICTION = 0.8
ROTATION_SPEED = 6
ACCELERATION = 0.9
ENEMY_FREQUENCY = 0.008 

#----------------------------------------ENUMERATIONS---------------------------------------
    # decides overlapping
    module ZOrder
        BACKGROUND, MIDDLE, BULLET, PLAYER, TOP = *0..4
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


# BULLET CLASS--------------------------------------------------------------------------

    class Bullet
        attr_accessor :x, :y, :angle, :speed, :image, :radius

        def initialize(x, y, angle, speed = 10)
            @x = x 
            @y = y 
            @angle = angle
            @radius = 3
            @speed = speed

            @image = Gosu::Image.new('Sprites/images/ammo6.png')
        end
    end

# ENEMY CLASS--------------------------------------------------------------------------

    class Enemy
        attr_accessor :x, :y, :radius, :speed, :image, :angle
        def initialize(x,y,speed)
            @x = x 
            @y = y
            @speed = speed
            @radius = 30
            @angle = 0
            @image = Gosu::Image.new('Sprites/images/aliens3.png')

        end

    end

# HOURGLASS CLASS

    class Hourglass
        attr_accessor :x, :y, :image
        def initialize(x,y)
            @image = Gosu::Image.new('Sprites/images/hourglass.png')
            @x = x
            @y = y 
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


# BULLET FUNCTIONS------------------------------------------------------------------------
def bullet_move(bullet)
    bullet.x += Gosu.offset_x(bullet.angle, bullet.speed)
    bullet.y += Gosu.offset_y(bullet.angle, bullet.speed)
end

def onscreen?(radius,x,y)
    right = SCREEN_WIDTH + radius
    left = -radius
    top = -radius
    bottom = SCREEN_HEIGHT + radius
    return(x > left and x < right and y > top and y < bottom)
end

# ENEMY FUNCTIONS

    # makes the enemy move in the player's direction
    def enemy_move(enemy,direction)
        enemy.angle = direction
        enemy.x += Gosu.offset_x(direction + 135,enemy.speed)
        enemy.y += Gosu.offset_y(direction + 135,enemy.speed)
    end

    # calculates the angle between enemy and the player
    def enemy_direction(player,enemy)
        angle = Gosu.angle(player.x, player.y, enemy.x, enemy.y)
        return angle
    end

# MAIN CLASS--------------------------------------------------------------------------------
class TankBattle < Gosu::Window


    def initialize
        # preparing the game window
        super(SCREEN_WIDTH, SCREEN_HEIGHT)
        self.caption = 'Tank Battle'

        @player = Player.new()
        @enemy_speed = 3
        # Arrays to keep track of sprites
        @enemies = [Enemy.new(0,0,@enemy_speed)]
        @bullets = []   
        @enemies_killed = 0 
        @hourglasses = [] 

        # Font
        @font30 = Gosu::Font.new(30)
        @font60 = Gosu::Font.new(60)

        # true if it's hourglass mode
        @hourglass_on = false
        @hourglass_image = Gosu::Image.new('Sprites/images/hourglass.png')
        
        # scenes
        @game_over = false
        @game_over_scene = Gosu::Image.new('game_over.png')

        #timer
        @clock_image = Gosu::Image.new('clock.png')
        @game_start_time = Gosu.milliseconds


    end

    def button_down(id)
        # make a bullet when space is pressed
        if id == Gosu::KbSpace

            x = @player.x 
            y= @player.y
            
            @bullets.push(Bullet.new(x, y, @player.angle))
        end

        # lets the player try again once the game is over
        if (@game_over)
            if id == Gosu::MS_LEFT 
                if mouse_x > 500 and mouse_x < 700 and mouse_y > 495 and mouse_y < 520
                    #reinitialize the arrays
                    @game_over = false
                    @enemies.clear()
                    @player.x = 300
                    @player.y = 400
                    @time_elapsed = 0
                    @game_start_time = Gosu.milliseconds
                    @enemies_killed = 0
                    @hourglasses.clear()
                    @hourglass_on = false
                end
            end
        end
    end

    def update()



        if (!@game_over)

            @time_elapsed = (Gosu.milliseconds - @game_start_time)/1000
        
            # MOVEMENT
            # Rotating the tank on button press
            player_turn_right(@player) if button_down?(Gosu::KB_RIGHT)
            player_turn_left(@player) if button_down?(Gosu::KB_LEFT)


            # moving the tank forward
            player_accelerate(@player) if button_down?(Gosu::KB_UP)
            player_move(@player)

            # moving the bullets
            @bullets.each do |bullet|
                bullet_move(bullet)
            end

            # ADDING A NEW ENEMY DEPENDING ON A CERTAIN FREQUENCY
            if rand < ENEMY_FREQUENCY

                if rand < 0.5
                    enemy = Enemy.new(0, rand * SCREEN_HEIGHT, @enemy_speed)  
                else 
                    enemy = Enemy.new(rand * SCREEN_WIDTH, 0, @enemy_speed)  
                end

                @enemies.push(enemy)   
            end

            # ADDING A NEW HOUR GLASS DEPENDING ON CERTAIN FREQUENCY
            if rand < 0.001
                hourglass = Hourglass.new(rand * SCREEN_WIDTH, rand * SCREEN_HEIGHT)
                @hourglasses.push(hourglass)
            end

            # making the enemy move
            @enemies.each do |enemy|
                angle = enemy_direction(@player,enemy)
                enemy_move(enemy, angle)
            end

            # COLLISIONS
            # detecting collision between the bullets and the enemies
            @enemies.dup.each do |enemy|
                @bullets.dup.each do |bullet|
                    distance = Gosu.distance(enemy.x, enemy.y, bullet.x, bullet.y)
                    if distance < enemy.radius + bullet.radius + 5 # 5 is some buffer to hit enemy easily
                        @enemies_killed += 1

                        # deleting the enemy and the bullet after collision and adding an explosion
                        @enemies.delete(enemy)
                        @bullets.delete(bullet)
                    end    
                end

            end

            @hourglasses.dup.each do |hourglass|
                distance = Gosu.distance(hourglass.x, hourglass.y, @player.x, @player.y)
                if distance < @player.radius + 5
                    @hourglasses.delete(hourglass)
                    @hourglass_on = true
                    @hourglass_time = Gosu.milliseconds
                end
            end

            if (@hourglass_on)
                @enemies.each do |enemy|
                    enemy.speed = 2
                end
            else
                @enemies.each do |enemy|
                    enemy.speed = 4
                end
            end

            if (@hourglass_on)
                @enemy_speed = 1
                
                if ((Gosu.milliseconds - @hourglass_time) > 10000)
                    @hourglass_on = false
                    @enemy_speed = 2
                end
            end

            # CLEANING THE ARRAYS
            # deleting the enemies which are out of the window
            @enemies.dup.each do |enemy|
                if enemy.y > SCREEN_HEIGHT + enemy.radius
                    @enemies.delete(enemy)
                end
            end

            # deleting the bullets which are not onscreen
            @bullets.dup.each do |bullet|
                @bullets.delete(bullet) unless onscreen?(bullet.radius, bullet.x, bullet.y)
            end

        end

        # GAME OVER
        @enemies.dup.each do |enemy|
            distance = Gosu.distance(enemy.x, enemy.y, @player.x, @player.y)
            if distance < enemy.radius + @player.radius 
                @game_over = true
                @game_over_message = "KILLED BY AN ENEMY"

            end
        end

        if (@time_elapsed == 200)
            @game_over = true
            @game_over_message = "------TIME IS UP------"
        end
        
    end

    def draw()

        if (!@game_over)
            # BACKGROUND
            draw_rect(0,0,SCREEN_WIDTH,SCREEN_HEIGHT,Gosu::Color.argb(0xff_808080),ZOrder::BACKGROUND, mode = :default)

            # PLAYER
            @player.image.draw_rot(@player.x, @player.y, ZOrder::PLAYER, @player.angle)

            # BULLETS
            @bullets.each do |bullet|
                bullet.image.draw_rot(bullet.x , bullet.y , ZOrder::BULLET, bullet.angle)
            end

            @hourglasses.each do |hourglass|
                hourglass.image.draw(hourglass.x, hourglass.y, ZOrder::PLAYER)
            end

            # ENEMY
            @enemies.each do |enemy|
                enemy.image.draw_rot(enemy.x, enemy.y, ZOrder::PLAYER, enemy.angle)
            end

            #SCORE
            @font30.draw_text("Enemies killed: #{@enemies_killed}", 0,0, 2, 1,1, 0xff_000000)
            if (@hourglass_on)
                @font30.draw_text("#{(10 - (Gosu.milliseconds - @hourglass_time)/1000)}",SCREEN_WIDTH-80, 20, 1)
                @hourglass_image.draw(SCREEN_WIDTH-120, 20)
            end

            #TIMER
            @clock_image.draw(SCREEN_WIDTH-100, SCREEN_HEIGHT-100, ZOrder::TOP, scale_x = 0.2, scale_y = 0.2)
            @font30.draw_text("#{@time_elapsed}", SCREEN_WIDTH-50, SCREEN_HEIGHT - 80, ZOrder::TOP, 1, 1,0xff_000000)

        else
            @game_over_scene.draw(0,0,ZOrder::TOP)
            @font60.draw_text("Score: #{@enemies_killed}", 500, 80, ZOrder::TOP, 1, 1, 0xff_ffffff )
            @font30.draw_text("#{@game_over_message}", 480, 190, ZOrder::TOP, 1, 1, 0xff_ff0000 )
        end
    end
end

window = TankBattle.new()
window.show()