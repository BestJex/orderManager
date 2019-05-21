package com.manager.mapper;

import com.manager.entity.Role;
import com.manager.util.MyMapper;

import java.util.List;

public interface RoleMapper extends MyMapper<Role> {

    List<Role> selectRolesByUserId(Integer userid);

}