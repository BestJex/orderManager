package com.manager.service;

import com.manager.entity.Menu;

import java.util.HashMap;
import java.util.List;

public interface MenuService extends IService<Menu>{

    List<Menu> selectMenusByRoleId(Integer roleid);

    List<Menu> selectByParentIdAndRoleId(HashMap<String, Object> paraMap);


}