local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")
local screenGui=Instance.new("ScreenGui",playerGui)
local mainFrame=Instance.new("Frame",screenGui)
mainFrame.Size=UDim2.new(0,220,0,350)
mainFrame.Position=UDim2.new(0,50,0,50)
mainFrame.BackgroundColor3=Color3.fromRGB(40,40,40)
mainFrame.Visible=false
local toggleButton=Instance.new("TextButton",screenGui)
toggleButton.Size=UDim2.new(0,120,0,50)
toggleButton.Position=UDim2.new(0,50,0,10)
toggleButton.Text="Toggle ESP Menu"
toggleButton.MouseButton1Click:Connect(function() mainFrame.Visible=not mainFrame.Visible end)
local brainrotNames={"Tralalero Tralala","Bombardiro Crocodilo","Tung Tung Tung Sahur","Lirilì Larilà","Chimpanzini Bananini","Ballerina Cappuccina","Shpioniro Golubiro","Tripi Tripo","Bombombini Gusini","Boneca Ambalabu","Brr Brr Patapim"}
local function createESP(part)
 if not part:FindFirstChild("ESPBox") then
  local box=Instance.new("BoxHandleAdornment")
  box.Name="ESPBox"
  box.Adornee=part
  box.Color3=Color3.fromRGB(255,0,0)
  box.Transparency=0.5
  box.Size=part.Size+Vector3.new(0.5,0.5,0.5)
  box.AlwaysOnTop=true
  box.Parent=part
 end
end
RunService.RenderStepped:Connect(function()
 for _,model in pairs(workspace:GetChildren()) do
  if model:IsA("Model") then
   for _,name in pairs(brainrotNames) do
    if model.Name==name then
     for _,part in pairs(model:GetChildren()) do
      if part:IsA("BasePart") then createESP(part) end
     end
    end
   end
  end
 end
end)
