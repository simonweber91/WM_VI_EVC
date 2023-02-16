function response = get_response(Experiment, responseType)

Keys = Experiment.Keys;
Timing = Experiment.Timing;
        
switch responseType
    
    case 'continue'
        
        % Wait for response
        keyIsDown = 0;
        while 1     % Infinite loop of keyboard checks
            [keyIsDown, secs, keyCode] = KbCheck;
            if keyIsDown
                keyIndex = find(keyCode==1);
                if ismember(keyIndex,Keys.responseKeys)
                    break ;
                elseif keyCode(Keys.escKey)  % break out of experiment, save log
                    ShowCursor;
                    save_log(Experiment);
                    Screen('CloseAll');
                    end_eyetracker(Experiment)
                    return;
                end
            end
        end
        WaitSecs(Timing.waitSecs);
        
    case 'control'
        
        % Wait for response
        keyIsDown = 0;
        while 1     % Infinite loop of keyboard checks
            [keyIsDown, secs, keyCode] = KbCheck;
            if keyIsDown
                keyIndex = find(keyCode==1);
                if ismember(keyIndex,Keys.controlKeys)
                    break ;
                elseif keyCode(Keys.escKey)  % break out of experiment, save log
                    ShowCursor;
                    save_log(Experiment);
                    Screen('CloseAll');
                    end_eyetracker(Experiment)
                    return;
                end
            end
        end
        
    case 'binary'
        
        % careful: use arrows for behavior and numbers [1 2] for MRI
        
        response = [];
        [keyIsDown, secs, keyCode] = KbCheck;
        if keyIsDown
            if keyCode(Keys.leftArrow) 
                response = -1;
            elseif keyCode(Keys.rightArrow)
                response = 1;
            % If escape key is pressed, save Log and close session
            elseif keyCode(Keys.escKey)
                ShowCursor;
                save_log(Experiment);
                Screen('CloseAll');
                end_eyetracker(Experiment)
                return;
            end
        end
        
    case 'continuous'
        
        response = 0;
        [keyIsDown, secs, keyCode] = KbCheck;
        if keyIsDown
            % If right arrow is pressed, move right on scale
            if keyCode(Keys.three) || keyCode(Keys.leftArrow)
                response = -1.5;
            % If left arrow is pressed, move left on scale
            elseif keyCode(Keys.four) || keyCode(Keys.rightArrow)
                response = 1.5;
            % terminates while loop from which this is called to "log in"
            % answer
            elseif keyCode(Keys.two) || keyCode(Keys.spaceKey)
                response = -9999;
            % If escape key is pressed, save Log and close session
            elseif keyCode(Keys.escKey)
                ShowCursor;
                save_log(Experiment);
                Screen('CloseAll');
                end_eyetracker(Experiment)
                return;
            end
        end
        
    case 'rating'
        
        response = [];
        keyIsDown = 0;
        [keyIsDown, secs, keyCode] = KbCheck;
        if keyIsDown
            if keyCode(Keys.one) 
                response = 1;
            elseif keyCode(Keys.two)
                response = 2;
            elseif keyCode(Keys.three)
                response = 3;
            elseif keyCode(Keys.four)
                response = 4;
            % If escape key is pressed, save Log and close session
            elseif keyCode(Keys.escKey)
                ShowCursor;
                save_log(Experiment);
                Screen('CloseAll');
                end_eyetracker(Experiment)
                return;
            end
        end
        
    case 'exit'
        
        keyIsDown = 0;
        [keyIsDown, secs, keyCode] = KbCheck;
        if keyIsDown
            if keyCode(Keys.escKey)
                ShowCursor;
                save_log(Experiment);
                Screen('CloseAll');
                end_eyetracker(Experiment)
                return;
            end
        end
        

end