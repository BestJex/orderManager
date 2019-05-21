package com.manager.mapper;

import com.manager.entity.Menu;
import com.manager.util.MyMapper;

import java.util.HashMap;
import java.util.List;

public interface MenuMapper extends MyMapper<Menu> {

    List<Menu> selectMenusByRoleId(Integer roleid);

    List<Menu> selectByParentIdAndRoleId(HashMap<String,Object> paraMap);

}