package com.manager.entity.converter;

import com.manager.entity.Role;
import com.manager.service.dto.role.RoleAddRequest;
import com.manager.service.dto.role.RoleEditRequest;
import org.springframework.util.Assert;

import javax.validation.constraints.NotNull;

public class RoleConverter {

    public static Role addRequestToRole(@NotNull Role role, @NotNull RoleAddRequest request) {
        Assert.notNull(role, "role could not be null");
        Assert.notNull(request, "requestRole could not be null");
        role.setName(request.getName());
        role.setRemark(request.getRemark());
        return role;
    }

    public static Role editRequestToRole(@NotNull Role role, @NotNull RoleEditRequest request) {
        Assert.notNull(role, "role could not be null");
        Assert.notNull(request, "requestRole could not be null");
        role.setName(request.getName());
        role.setRemark(request.getRemark());
        return role;
    }
}
