function Output = differentialRender( InputPhotograph, RenderWithObject, RenderWithoutObject, ObjectMask)
    Output = ((RenderWithObject - RenderWithoutObject + InputPhotograph) .* (1.0 - ObjectMask)) + (RenderWithObject .* ObjectMask);
end