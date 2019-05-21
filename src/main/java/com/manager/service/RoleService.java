package com.manager.service;

import com.manager.entity.Role;

import java.util.List;

public interface RoleService extends IService<Role>{


    //根据userid查询所有的角色
    List<Role> selectRolesByUserId(Integer userid);

}