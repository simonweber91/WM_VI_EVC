function response = localizer_response(Localizer)

Keys = Localizer.Keys;

response = NaN;
[keyIsDown, secs, keyCode] = KbCheck;
if keyIsDown
    keyIndex = find(keyCode==1);
    if ismember(keyIndex,Keys.responseKeys)
        response = 1;
    elseif keyCode(Keys.escKey)
        save([Localizer.Subject.out,'.mat'],'Localizer');
        ShowCursor;
        Screen('CloseAll');
        return;
    end
end