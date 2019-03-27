function setPosition(lib,axis,position)

Pos = getPositionerSettings(lib);
if axis == Pos.Z.Axis
    error('It is not safe to use this function to re-map the z-axis')
end

calllib(lib,'SetPosition',axis,position);