package com.manager.service.impl;

import com.manager.entity.Role;
import com.manager.mapper.RoleMapper;
import com.manager.service.RoleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * @author manager
 * @version 1.0, 2017/11/10
 * @description
 */

@Service("troleService")
public class RoleServiceImpl extends BaseService<Role> implements RoleService {
    @Autowired
    private RoleMapper roleMapper;

    @Override
    public List<Role> selectRolesByUserId(Integer userid) {
        return roleMapper.selectRolesByUserId(userid);
    }
}
