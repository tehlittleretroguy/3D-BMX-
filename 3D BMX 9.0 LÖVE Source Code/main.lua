--features: Object Space and 3d projection with a little cube
local nearPlane = 0.1
local moveSpeed = 5
local rotationX = 0 
local rotationY = 0
local rotationZ = 0
local rotationXCam = 0 
local rotationYCam = 0
local rotationZCam = 0
local rotationSpeed = 5
local faceMesh

vertexFormat = {
    
    {"VertexPosition", "float", 2},
    {"VertexTexCoord", "float", 2}
}

local textureData
local frameData
local frameImage

local screenWidth = 320
local screenHeight = 280

local palette = {
  
   black = {0, 0, 0},
   darkBlue = {0, 0, 128},
   darkGreen = {0, 128, 0},
   darkCyan = {0, 128, 128},
   darkRed = {128, 0, 0},
   darkMagenta = {128, 0, 128},
   brown = {170, 85, 0},
   brightGrey = {170, 170, 170},
   darkGrey = {85, 85, 85},
   brightBlue = {85, 85, 255},
   brightGreen = {85, 255, 85},
   brightCyan = {85, 255, 255},
   brightRed = {255, 85, 85},
   brightMagenta = {255, 85, 255},
   yellow = {255, 255, 85},
   white = {255, 255, 255}

}



local pointA = {
  
   x = 4,
   y = 2,
   z = 6
   
}

local pointB = {
  
    x = 1,
    y = 2,
    z = 2
    
}

--dx = 3
local dx = pointA.x - pointB.x
--dy = 0
local dy = pointA.y - pointB.y
--dz = 4
local dz = pointA.z - pointB.z

local distance = {
  
  dx2 = dx * dx,
  dy2 = dy * dy,
  dz2 = dz * dz
  
}

local sum = distance.dx2 + distance.dy2 + distance.dz2
local distance3D = math.sqrt(sum)

local cube = {
  
   x = 0, 
   y = 0, 
   z = 0,
   
   vertices = {
   
     point1 = {
     
     x = -5,
     y = -1,
     z = -5
    
    },
   
    point2 = {
     
     x = 5,
     y = -1,
     z = -5
     
    },
   
    point3 = {
     
     x = 5,
     y = 1,
     z = -5
     
    },
   
    point4 = {
     
     x = -5,
     y = 1,
     z = -5
     
    },
   
    point5 = {
     
     x = -5,
     y = -1, 
     z = 5
     
    },
   
    point6 = {
     
     x = 5,
     y = -1,
     z = 5
     
    },
   
    point7 = {
     
     x = 5,
     y = 1,
     z = 5
     
    },
   
    point8 = {
     
     x = -5,
     y = 1,
     z = 5
     
    },
    
  }
   
}

camera = {
  
  x = 0,
  y = 0,
  z = -5
  
}

local faces = {
  
    {
      
        vertices = {"point4", "point3", "point7", "point8"},

        uvs = {0, 0, 1, 0, 1, 1, 0, 1}
        
    }
    
}


function connectPoints(from, to)
     
    local edge = {
      
       from = from,
       to = to
       
    }
    
    return edge
    
end



function getWorldPosition(point, object)
  
  local worldPosition = {
    
    
    posX = point.x + object.x,
    posY = point.y + object.y,
    posZ = point.z + object.z
    
  }
  
  return worldPosition
  
end

local d = distance.dx2 + distance.dy2 + distance.dz2
local dSqrt = math.sqrt(d)

local result = getWorldPosition(cube.vertices.point3, cube)

function projectPoint(point)
  
    
    local focalLength = 100
    local screenWidth = 320
    local screenHeight = 280
    local screenCenterX = screenWidth / 2
    local screenCenterY = screenHeight / 2
    local depth = point.z
    local depthX = point.x 
    local depthY = point.y
    
    
    --6bit Software Zbuffer
    
    local depthLevels = 63
    local maxDepthValue = 64
    
    
    if depth < nearPlane then
      
        return nil
    end
        
    local screenPoint = {
      
      x = (depthX * focalLength) / depth + screenCenterX,
      y = screenCenterY - (depthY * focalLength) / depth
      
    }
    
    
    
    return screenPoint
    
end
  

 


function projectEdge(edge)
         
         
    local worldFrom = getWorldPosition(cube.vertices[edge.from], cube)
    
    local worldTo = getWorldPosition(cube.vertices[edge.to], cube)
    
    local cameraInput = {
      
      x = worldFrom.posX,
      y = worldFrom.posY,
      z = worldFrom.posZ
      
    }
    
    local cameraInputTo = {
      
      x = worldTo.posX,
      y = worldTo.posY,
      z = worldTo.posZ
      
    }
    
    local fromPoint = rotateCamera(cameraInput)
    
    local toPoint = rotateCamera(cameraInputTo)
    
    
    
    local depthA = fromPoint.z
    
    local depthB = toPoint.z
    
    if depthA <= nearPlane and depthB <= nearPlane then
      
        return nil
      
    end
    
  
    
    if depthA <= nearPlane or depthB <= nearPlane then
    
        local t = (nearPlane - depthA) / (depthB - depthA)
    
        local intersection = {
      
          x = fromPoint.x + t * (toPoint.x - fromPoint.x),
          y = fromPoint.y + t * (toPoint.y - fromPoint.y),
          z = fromPoint.z + t * (toPoint.z - fromPoint.z)
          
      
        }
     
        if depthA <= nearPlane then
        
            fromPoint = intersection
      
        else
    
            toPoint = intersection
      
      end
      
      
      
        
      
    end
  
    
    
    local projectedFrom = projectPoint(fromPoint)
    local projectedTo = projectPoint(toPoint)
    
    if projectedFrom == nil or projectedTo == nil then
          return nil

      end
    
    
    local projected =  {
      
       from = projectedFrom,
       to = projectedTo
       
    }
    
    return projected
    
    
    
end

function clipPolygonNearPlane(vertices)
  
    local clippedVertices = {}
    
    local previous = vertices[#vertices]
    local previousInside = previous.z >= nearPlane
    
    
    for i, current in ipairs(vertices) do
      
        
    
        local currentInside = current.z >= nearPlane 
        
        if currentInside ~= previousInside then
        
            local t = (nearPlane - previous.z) / (current.z - previous.z)
            
            local intersection = {
          
              x = previous.x + t * (current.x - previous.x),
              y = previous.y + t * (current.y - previous.y),
              z = previous.z + t * (current.z - previous.z),
              
              u = previous.u + t * (current.u - previous.u),
              v = previous.v + t * (current.v - previous.v)
              
            }
            
            intersection.inverseDepth = 1 / intersection.z
            intersection.uOverZ = intersection.u * intersection.inverseDepth
            intersection.vOverZ = intersection.v * intersection.inverseDepth
              
                table.insert(clippedVertices, intersection)
                
            
          
        end
        
        if currentInside then
          
            table.insert(clippedVertices, current)
            
        end
            
        previous = current
        previousInside = currentInside
        
    end
    
    for _, point in ipairs(clippedVertices) do
      
        local inverseDepth = 1 / point.z
    
        local uOverZ = point.u * inverseDepth
        local vOverZ = point.v * inverseDepth
      
         point.inverseDepth = inverseDepth
         point.uOverZ = uOverZ
         point.vOverZ = vOverZ
      
    end
    return clippedVertices
    
end

function projectFace(face)
  
    
    local projectedVertices = {}
    local meshVertices = {}
    local cameraVertices = {}
    
    
    for i, value in ipairs(face.vertices) do
      
      
      
      local vertex = cube.vertices[value]

      local world = getWorldPosition(vertex, cube)
      
      local cameraPoint = {
        
        x = world.posX,
        y = world.posY,
        z = world.posZ
        
      }
      
      
      
      local transformedPoint = rotateCamera(cameraPoint)
      
      transformedPoint.u = face.uvs[(i - 1) * 2 + 1]
      transformedPoint.v = face.uvs[(i - 1) * 2 + 2]
      
      
      
      
      table.insert(cameraVertices, transformedPoint)
  
    end
  
  
      local clippedVertices = clipPolygonNearPlane(cameraVertices)
      
      if #clippedVertices < 3 then
        
          return nil
          
      end
    
    for i, point in ipairs(clippedVertices) do
    
        local screenPoint = projectPoint(point)
        
        if screenPoint ~= nil then
          
            table.insert(projectedVertices, {
                
                x = screenPoint.x,
                y = screenPoint.y,
                u = point.u,
                v = point.v,
                z = point.z,
                
                inverseDepth = point.inverseDepth,
                
                uOverZ = point.uOverZ,
                vOverZ = point.vOverZ
                
            })
        end
        
        
        
        
    end
    
    if #projectedVertices < 3 then
      
        return nil
        
    end
    
    for i = 2, #projectedVertices -1 do
      
      local p1 = projectedVertices[1]
      local p2 = projectedVertices[i]
      local p3 = projectedVertices[i + 1]
      
      table.insert(meshVertices, {
          
          p1.x, p1.y, p1.u, p1.v
          
      })
      table.insert(meshVertices, {
          
          p2.x, p2.y, p2.u, p2.v
          
      })
    
      table.insert(meshVertices, {
          
          p3.x, p3.y, p3.u, p3.v
      })
    
    
    end
    
  
    
      
    
    
    
    
    
    return projectedVertices
end
local edges = {
  
  connectPoints("point1", "point2"),
  connectPoints("point2", "point3"),
  connectPoints("point3", "point4"),
  connectPoints("point4", "point1"),
  connectPoints("point5", "point6"),
  connectPoints("point6", "point7"),
  connectPoints("point7", "point8"),
  connectPoints("point8", "point5"),
  connectPoints("point1", "point5"),
  connectPoints("point2", "point6"),
  connectPoints("point3", "point7"),
  connectPoints("point4", "point8")
  
}

projectedEdges = {}



function love.load()
  
  
  love.window.setMode(320, 280)
  love.window.setTitle("3D BMX in construction")
  
  textureData = love.image.newImageData("assets/Baseplate Texture.png")
  texture = love.graphics.newImage(textureData)
  texture:setWrap("repeat", "repeat")
  
  
  
  frameData = love.image.newImageData(screenWidth, screenHeight)
  
  frameImage = love.graphics.newImage(frameData)
  
  
  
end
 
  
function rotatePoint(point)
    
    
    cosY = math.cos(rotationY)
    sinY = math.sin(rotationY)
    
    cosZ = math.cos(rotationZ)
    sinZ = math.sin(rotationZ)
    
    cosX = math.cos(rotationX)
    sinX = math.sin(rotationX)
    
    rotatedX = point.x * cosY + point.z * sinY  
    
    rotatedZ = -point.x * sinY + point.z * cosY
  
    rotatedY = point.y
    
    rotatedPoint = {
      
      x = rotatedX,
      y = rotatedY,
      z = rotatedZ
      
    }
    
    return rotatedPoint
    
end

function rotateCamera(angle)
  
    cosYCam = math.cos(rotationYCam)
    sinYCam = math.sin(rotationYCam)
    
    local cosXCam = math.cos(rotationXCam)
    local sinXCam = math.sin(rotationXCam)
    
    local cosZCam = math.cos(rotationZCam)
    local sinZCam = math.sin(rotationZCam)
    
    local relativeX = angle.x - camera.x
    
    local relativeY = angle.y - camera.y
    
    local relativeZ = angle.z - camera.z
    
    local firstXCam = relativeX * cosYCam
    local secondXCam = relativeZ * sinYCam
    
    local rotatedXCam = firstXCam - secondXCam
    
    local firstZCam = relativeX * sinYCam
    local secondZCam = relativeZ * cosYCam
    
    local rotatedZCam = firstZCam + secondZCam
    
    
    
    return {
      
      x = rotatedXCam,
      y = relativeY,
      z = rotatedZCam
      
    }
    
end



testPointCamera = rotateCamera(camera)
testPoint = rotatePoint(cube.vertices.point1)


function updateProjection()
  
    projectedEdges = {}
    
    for i, edge in ipairs(edges) do
        
        local projected = projectEdge(edge)
        
        if projected ~= nil then
          
           table.insert(projectedEdges, projected)
           
        end
        
    end
    
end

function edgeFunction(a, b, x, y)
  
    local dx1 = x - a.x
    local dy1 = y - a.y
    local dx2 = b.x - a.x
    local dy2 = b.y - a.y
    local result = (dx1 * dy2) - (dy1 * dx2)
    
    return result
    
  
end


function renderSoftwareFaces()



    for y = 0, screenHeight - 1 do
  
       for x = 0, screenWidth - 1 do
      
           frameData:setPixel(x, y, 0, 0, 0, 1)
        
       end
    
    end
   
    for _, face in ipairs(faces) do
     
        local points = projectFace(face)
        
        if points ~= nil then
          
            for i = 2, #points - 1 do
              
                local p1 = points[1]
                local p2 = points[i]
                local p3 = points[i + 1]
                local minX = math.floor(math.min(p1.x, p2.x, p3.x))
                local maxX = math.ceil(math.max(p1.x, p2.x, p3.x))
                
                local minY = math.floor(math.min(p1.y, p2.y, p3.y))
                local maxY = math.ceil(math.max(p1.y, p2.y, p3.y))
                
                minX = math.max(0, minX)
                maxX = math.min(screenWidth - 1, maxX)
                
                minY = math.max(0, minY)
                maxY = math.min(screenHeight - 1, maxY)
                
                for y = minY, maxY do
                  
                    for x = minX, maxX do
                      
                      local w1 = edgeFunction(p2, p3, x, y)
                      local w2 = edgeFunction(p3, p1, x, y)
                      local w3 = edgeFunction(p1, p2, x, y)
                      local inside = 
                      
                      (w1 >= 0 and w2 >= 0 and w3 >= 0)
                      or
                      (w1 <= 0 and w2 <= 0 and w3 <= 0)
                      
                      if inside then
                        
                          local area = edgeFunction(p1, p2, p3.x, p3.y)
                          if area ~= 0 then
                            
                            local alpha = edgeFunction(p2, p3, x, y) / area
                            local beta = edgeFunction(p3, p1, x, y) / area
                            local gamma = edgeFunction(p1, p2, x, y) / area
                            
                            local inverseDepth = alpha * p1.inverseDepth + beta * p2.inverseDepth + gamma * p3.inverseDepth
                            
                            local uOverZ = 
                              alpha * p1.uOverZ + beta * p2.uOverZ + gamma * p3.uOverZ
                              
                            local vOverZ = alpha * p1.vOverZ + beta * p2.vOverZ + gamma * p3.vOverZ
                            
                            local u = uOverZ / inverseDepth
                            local v = vOverZ / inverseDepth
                            
                            if inverseDepth > 0 then
                              
                                local textureWidth = textureData:getWidth()
                                local textureHeight = textureData:getHeight()
                                
                                local texX = math.floor(u * textureWidth)
                                local texY = math.floor(v * textureHeight)
                                
                                texX = math.max(0, math.min(textureWidth - 1, texX))
                                texY = math.max(0, math.min(textureHeight - 1, texY))
                                local r, g, b, a = textureData:getPixel(texX, texY)
                                frameData:setPixel(x, y, r, g, b, a)
                                
                            end
                             
                          end
                        
                      end
                      
                    end
                    
                end
                
            end
            
            
            
        end
    end
    
    frameImage:refresh(frameData)
    
end


            
        

function love.draw()
   
   renderSoftwareFaces()
   
   love.graphics.draw(frameImage, 0, 0)
   
   for _, projected in ipairs(projectedEdges) do
      love.graphics.line(
        
        projected.from.x,
        projected.from.y,
        projected.to.x,
        projected.to.y
        
      )
   end
   
   
        
     
     
          
      
      
     
     
   
   
 
end

function love.update(dt)
  
    
    local cosYCam = math.cos(rotationYCam)
    local sinYCam = math.sin(rotationYCam)
        
    local moveX = sinYCam * moveSpeed * dt
    local moveZ = cosYCam * moveSpeed * dt
    
    
       
    
    if love.keyboard.isDown("w") then
      
      camera.x = camera.x + moveX
      camera.z = camera.z + moveZ
        
    elseif love.keyboard.isDown("s") then
      
      camera.z = camera.z - moveZ
      camera.x = camera.x - moveX
      
    end
    
    
    
    if love.keyboard.isDown("up") then
      
       camera.y = camera.y + moveSpeed * dt
       
    elseif love.keyboard.isDown("down") then
      
      camera.y = camera.y - moveSpeed * dt
      
    end
    
    if love.keyboard.isDown("left") then
      
        rotationYCam = rotationYCam - 2.5 * dt
      
    elseif love.keyboard.isDown("right") then
      
        rotationYCam = rotationYCam + 2.5 * dt
        
    end
    
      
      
    if love.keyboard.isDown("a") then
      
        local cosYCam = math.cos(rotationYCam)
        local sinYCam = math.sin(rotationYCam)
        
        local moveX = cosYCam * moveSpeed * dt
        local moveZ = -sinYCam * moveSpeed * dt
    
    
      
      camera.x = camera.x - moveX
      camera.z = camera.z - moveZ
      
    elseif love.keyboard.isDown("d") then
      
        local cosYCam = math.cos(rotationYCam)
        local sinYCam = math.sin(rotationYCam)
        
        local moveX = cosYCam * moveSpeed * dt
        local moveZ = -sinYCam * moveSpeed * dt
    
    
      camera.x = camera.x + moveX
      camera.z = camera.z + moveZ
      
    end
    
    updateProjection()
    
end


    
      
