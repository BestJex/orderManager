package com.manager.service.dto.user;

import com.manager.entity.Role;
import com.manager.entity.User;

import java.util.List;

public class UserInfoResponse {
    private List<Role> roleList;
    private List<Role> notInRolelist;
    private User user;

    public List<Role> getRoleList() {
        return roleList;
    }

    public void setRoleList(List<Role> roleList) {
        this.roleList = roleList;
    }

    public List<Role> getNotInRolelist() {
        return notInRolelist;
    }

    public void setNotInRolelist(List<Role> notInRolelist) {
        this.notInRolelist = notInRolelist;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }
}
