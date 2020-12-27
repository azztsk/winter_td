modifier_silenced = class({})

function modifier_silenced:CheckState() 
  local state = {
      [MODIFIER_STATE_SILENCED] = true,
  }

  return state
end

function modifier_silenced:IsHidden()
    return true
end