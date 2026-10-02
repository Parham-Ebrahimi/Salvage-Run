-- Play Server fixture; follow with actual W input for ~1.3 seconds and observe.
-- Run one stage per call (1, 5, 10). Does not fake movement or awards.
return function(stage)
 assert(game:GetService("RunService"):IsStudio() and game:GetService("RunService"):IsRunning(),"Studio Play only")
 assert(stage==1 or stage==5 or stage==10,"Acceptance stages")
 local bridge=game.ServerStorage.SalvageDebug
 bridge:SetAttribute("Command",game:GetService("HttpService"):JSONEncode({Action="EntryFixture",Args={Stage=stage},Nonce=os.clock()}))
 task.wait(.15)
 return bridge:GetAttribute("Result")
end
