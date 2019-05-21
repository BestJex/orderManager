package com.manager.service.impl;

import com.manager.entity.Menu;
import com.manager.mapper.MenuMapper;
import com.manager.service.MenuService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;

/**
 * @author manager
 * @version 1.0, 2017/11/10
 * @description
 */
@Service("tmenuService")
public class MenuServieImpl extends BaseService<Menu> implements MenuService {
    @Autowired
    private MenuMapper menuMapper;

    @Override
    public List<Menu> selectMenusByRoleId(Integer roleid) {
        return menuMapper.selectMenusByRoleId(roleid);
    }

    @Override
    public List<Menu> selectByParentIdAndRoleId(HashMap<String, Object> paraMap) {
        return menuMapper.selectByParentIdAndRoleId(paraMap);
    }
}
