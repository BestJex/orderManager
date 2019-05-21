package com.manager.entity.converter;

import com.manager.entity.User;
import com.manager.service.dto.user.UserAddRequest;
import com.manager.service.dto.user.UserEditRequest;
import com.manager.util.ShiroUtil;
import org.springframework.util.Assert;

import javax.validation.constraints.NotNull;

public class UserConverter {
    public static User addRequestToUser(@NotNull User user, @NotNull UserAddRequest request) {
        Assert.notNull(user, "user could not be null");
        Assert.notNull(request, "requestUser could not be null");
        user.setPassword(ShiroUtil.getSaltPwd(request.getUserName(), request.getPassword()));
        user.setUserName(request.getUserName());
        user.setTrueName(request.getTrueName());
        user.setRemark(request.getRemark());
        return user;
    }

    public static User editRequestToUser(@NotNull User user, @NotNull UserEditRequest request) {
        Assert.notNull(user, "user could not be null");
        Assert.notNull(request, "requestUser could not be null");
        user.setTrueName(request.getTrueName());
        user.setRemark(request.getRemark());
        return user;
    }
}
