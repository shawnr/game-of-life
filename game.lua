module(..., package.seeall)

--====================================================================--
-- SCENE: Conway's Game of Life
--====================================================================--

--[[

 - Version: 0.1
 - Made by: Shawn Rider
 - Website: http://shawnrider.com

******************
 - INFORMATION
******************

  - Just wanted to build my own...

--]]

new = function ()

    ------------------
    -- Groups
    ------------------

    local localGroup = display.newGroup()

    ------------------
    -- Game Code
    ------------------

    -- draw background
    local background = display.newImageRect("img/background.png", 1024, 768)
    background:setReferencePoint(display.CenterReferencePoint)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    localGroup:insert(background)
    localGroup['background'] = background

    print('put in background')

    -- Establish the table of entities
    local pixel_set = {}

    local col_counter = 1
    local row_counter = 1
    local game_initialized = false
    math.randomseed(os.time())

    while game_initialized == false do
        print('initializing game...')
        local rand_val = math.random(0,1)
        print('rand_val = '..rand_val)
        if pixel_set[row_counter] == nil then
            pixel_set[row_counter] = {} -- initialize row dictionary
        end
        if rand_val == 1 then
            pixel_set[row_counter][col_counter] = true
            print('set pixel_set['..row_counter..']['..col_counter..'] = true')
        else
            pixel_set[row_counter][col_counter] = false
            print('set pixel_set['..row_counter..']['..col_counter..'] = false')
        end
        if col_counter % 32 == 0 then
            print('starting new row')
            row_counter = row_counter + 1 -- bump up to the next row
            col_counter = 1 -- reset the pixel counter
            if row_counter > 24 then
                print('initialization complete.')
                game_initialized = true -- once we've drawn 24 rows we are done
            end
        else
            print('next column')
            col_counter = col_counter + 1
        end
    end

    localGroup['pixel_set'] = {} -- initialize pixel set
    -- Draw first set of icons
    function draw_pixels(group)
        print('drawing pixels')
        for row_num, row_data in ipairs(pixel_set) do
            for i, v in ipairs(row_data) do
                local this_pixel = display.newImageRect("img/pixel.png", 32, 32)
                this_pixel:setReferencePoint(display.CenterReferencePoint)
                this_pixel.x = (i * 32) - 16
                this_pixel.y = (row_num * 32) - 16

                if v == true then
                    print('drawing live pixel')
                    this_pixel:setFillColor(0, 255, 0, 255)
                else
                    print('drawing dead pixel')
                    this_pixel:setFillColor(0, 0, 0, 0)
                end

                if group['pixel_set'] == nil then
                    group['pixel_set'] = {}
                end
                if group['pixel_set'][row_num] == nil then
                    group['pixel_set'][row_num] = {}
                end
                if group['pixel_set'][row_num][i] == nil then
                    print('creating pixel for the very first time!')
                else
                    print('destroying old pixel')
                    group['pixel_set'][row_num][i]:removeSelf()
                    group['pixel_set'][row_num][i] = nil
                end
                print('inserting pixel')
                group:insert(this_pixel)
                group['pixel_set'][row_num][i] = this_pixel
            end
        end
    end

    draw_pixels(localGroup)

    function update_pixels(group)
        print('entered loop to update pixels')
        for row_num, row_data in ipairs(pixel_set) do
            print('entered row '..row_num..' to update')
            for i, v in ipairs(row_data) do
                print('entered row_data at: '..i)
                local life_counter = 0
                -- check top left pixel
                local row_minus = row_num - 1
                local col_minus = i - 1
                local row_plus = row_num + 1
                local col_plus = i + 1

                print('row: '..row_num..' row_minus: '..row_minus..' row_plus: '..row_plus)
                print('col: '..i..' col_minus: '..col_minus..' col_plus: '..col_plus)
                if row_minus > 0 and col_minus > 0 and pixel_set[row_minus][col_minus] == true then
                    print('top left alive')
                    life_counter = life_counter + 1
                end
                -- check left pixel
                if col_minus > 0 and pixel_set[row_num][col_minus] == true then
                    print('left alive')
                    life_counter = life_counter + 1
                end
                -- check bottom left pixel
                if row_plus < 25 and col_minus > 0  and pixel_set[row_plus][col_minus] == true then
                    print('bottom left alive')
                    life_counter = life_counter + 1
                end
                -- check top right pixel
                if row_minus > 0 and col_plus < 33 and pixel_set[row_minus][col_plus] == true then
                    print('top right alive')
                    life_counter = life_counter + 1
                end
                -- check the right pixel
                if col_plus < 33 and pixel_set[row_num][col_plus] == true then
                    print('right alive')
                    life_counter = life_counter + 1
                end
                -- check bottom right pixel
                if row_plus < 25 and col_plus < 33 and pixel_set[row_plus][col_plus] == true then
                    print('bottom right alive')
                    life_counter = life_counter + 1
                end
                -- check the top pixel
                if row_minus > 0 and pixel_set[row_minus][i] == true then
                    print('top alive')
                    life_counter = life_counter + 1
                end
                -- check the bottom pixel
                if row_plus < 25 and pixel_set[row_plus][i] == true then
                    print('bottom  alive')
                    life_counter = life_counter + 1
                end
                print('life_counter = '..life_counter)

                -- check life_counter and assign live/die
                local current_pixel_status = v
                local new_pixel_status = v

                if current_pixel_status == true then
                    print('current_pixel_status=true')
                    if life_counter < 2 then
                        print('pixel dies of loneliness!')
                        new_pixel_status = false
                    elseif life_counter == 2 or life_counter == 3 then
                        print('pixel stays alive!')
                        new_pixel_status = true
                    elseif life_counter > 3 then
                        print('pixel dies of overcrowding!')
                        new_pixel_status = false
                    end
                elseif current_pixel_status == false and life_counter == 3 then
                    print('current_pixel resurrected!')
                    new_pixel_status = true
                else
                    print('dead pixel stays dead')
                    new_pixel_status = false
                end

                -- Adjust data in pixel_set
                pixel_set[row_num][i] = new_pixel_status

                print('done updating pixel data')
            end
        end
        draw_pixels(group)
    end

    game_timer = {}
    function play_pause(event)
        print('play button pressed')
        if game_paused == true then
            print('un-pausing game')
            event.target.label = 'pause'
            game_paused = false
            local enc_update_pixels = function () return update_pixels(event.target.group) end
            game_timer = timer.performWithDelay(500, enc_update_pixels, 0)
        else
            print('pausing game')
            event.target.label = 'play'
            game_paused = true
            timer.cancel(game_timer)
            game_timer = nil
        end

        return true
    end

    local play_button = widget.newButton{
        label = "play",
        labelYOffset = 0,
        fontSize = 20,
        id = "edit_avatar", -- build string for decoding in listener
        labelColor = { default={255}, over={128} },
        defaultFile = 'img/button.png',
        overFile = 'img/button.png',
        width=200,
        height=50,
        onPress = play_pause,  -- event listener function
    }
    play_button:setReferencePoint(display.upperLeftReferencePoint)
    play_button.x = 10
    play_button.y = 10
    play_button.group = localGroup
    localGroup:insert(play_button)

    ------------------
    -- MUST return a display.newGroup()
    ------------------

    return localGroup

end
