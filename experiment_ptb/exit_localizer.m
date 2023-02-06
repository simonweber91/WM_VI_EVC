function exit_localizer(Localizer)
        keyIsDown=0;
        [keyIsDown, secs, keyCode] = KbCheck;
        if keyIsDown
            if keyCode(KbName('ESCAPE'))
                save([Localizer.Subject.out,'.mat'],'Localizer');
                ShowCursor;
                Screen('CloseAll');
                return;
            end
        end
end