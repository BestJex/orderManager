package com.manager.controller;

import com.github.pagehelper.PageHelper;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.manager.entity.Menu;
import com.manager.entity.Role;
import com.manager.entity.Rolemenu;
import com.manager.entity.Userrole;
import com.manager.entity.converter.RoleConverter;
import com.manager.model.PageRusult;
import com.manager.service.*;
import com.manager.service.dto.role.RoleAddRequest;
import com.manager.service.dto.role.RoleEditRequest;
import com.manager.service.dto.role.RoleListRequest;
import com.manager.service.dto.role.RoleListResponse;
import com.manager.util.ResponseMessage;
import org.apache.commons.lang3.StringUtils;
import org.apache.shiro.authz.annotation.RequiresPermissions;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import tk.mybatis.mapper.entity.Example;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import java.util.*;

/**
 * 后台管理用户Controller
         *
         * @author manager
        */
@Controller
@RequestMapping("/admin/role")
public class RoleController {

    @Resource
    private RoleService roleService;

    @Resource
    private UserroleService userRoleService;

    @Resource
    private MenuService menuService;

    @Resource
    private RolemenuService roleMenuService;


    @RequestMapping(value = "/index", method = RequestMethod.GET)
    @RequiresPermissions(value = {"角色管理"})
    public String index() {
        return "admin/role/index";
    }

    @RequestMapping(value = "/create", method = RequestMethod.GET)
    @RequiresPermissions(value = {"角色管理"})
    public String createIndex() {
        return "admin/role/create";
    }

    /**
     * 分页查询角色信息
     */

    @ResponseBody
    @RequestMapping(value = "/list", method = RequestMethod.GET)
    @RequiresPermissions(value = {"角色管理"})
    public ResponseMessage list(RoleListRequest request) throws Exception {

    Example troleExample = new Example(Role.class);
    //tuserExample.or().andIdNotEqualTo(1L);
    Example.Criteria criteria = troleExample.or();

    if (StringUtils.isNotEmpty(request.getName())) {
        criteria.andEqualTo("name",request.getName());
     }
    PageHelper.startPage(request.getPage(), request.getLimit());
    List<Role> roleList = roleService.selectByExample(troleExample);
    PageRusult<Role> pageRusult =new PageRusult<Role>(roleList);

    RoleListResponse data = new RoleListResponse();
    data.setCount((int)pageRusult.getTotal());
    data.setItems(roleList);
    return ResponseMessage.initializeSuccessMessage(data);
}


    @ResponseBody
    @RequestMapping(value = "/add", method = RequestMethod.POST)
    @RequiresPermissions(value = {"角色管理"})
    public ResponseMessage addRole(RoleAddRequest request) {
        try {
            Example troleExample = new Example(Role.class);
            troleExample.or().andEqualTo("name",request.getName());
            List<Role> rolelist = roleService.selectByExample(troleExample);
            if (rolelist != null && rolelist.size() > 0) {
                return new  ResponseMessage(ResponseMessage.PARAMETER_ERROR,"当前角色名已存在");
            }
            Role role = new Role();
            role = RoleConverter.addRequestToRole(role, request);
            roleService.saveNotNull(role);
            return ResponseMessage.initializeSuccessMessage(null);
        } catch (Exception e) {
            return new ResponseMessage(ResponseMessage.SYSTEM_ERROR, "操作失败，系统异常");
        }
    }

    @ResponseBody
    @RequestMapping(value = "/edit",method = RequestMethod.POST)
    @RequiresPermissions(value = {"角色管理"})
    public ResponseMessage editRole(RoleEditRequest request) {
        try {

                Role role = roleService.selectByKey(request.getId());
                if (role == null) {
                    return new ResponseMessage(ResponseMessage.PARAMETER_ERROR,"当前角色名不存在");
                } else {
                    role = RoleConverter.editRequestToRole(role, request);
                    roleService.updateNotNull(role);

            }
            return ResponseMessage.initializeSuccessMessage(null);
        } catch (Exception e) {
            return new ResponseMessage(ResponseMessage.SYSTEM_ERROR, "操作失败，系统异常");
        }
    }


    @ResponseBody
    @RequestMapping(value = "/delete" ,method = RequestMethod.POST)
    @RequiresPermissions(value = {"角色管理"})
    public ResponseMessage deleteRole(@RequestParam("id") Integer id) {
        try {
            Role role = roleService.selectByKey(id);
            if (role == null) {
                return new ResponseMessage(ResponseMessage.PARAMETER_ERROR, "删除失败,无法找到该记录");
            } else {
                //还需删除用户角色中间表
                Example tuserroleexample = new Example(Userrole.class);
                tuserroleexample.or().andEqualTo("roleId",id);
                userRoleService.deleteByExample(tuserroleexample);
                Example trolemenuexample = new Example(Rolemenu.class);
                trolemenuexample.or().andEqualTo("roleId",id);
                roleMenuService.deleteByExample(trolemenuexample);

                roleService.delete(id);
            }
            return ResponseMessage.initializeSuccessMessage(null);
        } catch (Exception e) {
            e.printStackTrace();
            return new ResponseMessage(ResponseMessage.SYSTEM_ERROR,"删除失败，系统异常");
        }
    }


    @ResponseBody
    @RequestMapping(value = "/info", method = RequestMethod.POST)
    @RequiresPermissions(value = {"角色管理"})
        public ResponseMessage roleInfo(@RequestParam("id") Integer id) {
        try {
            Role role = roleService.selectByKey(id);
            if (role == null) {
                return new ResponseMessage(ResponseMessage.PARAMETER_ERROR,"无法找到该记录");
            }
            return ResponseMessage.initializeSuccessMessage(role);
        } catch (Exception e) {
            return new ResponseMessage(ResponseMessage.SYSTEM_ERROR,  "获取失败，系统异常");
        }
    }


    /**
     * 根据父节点获取所有复选框权限菜单树
     *
     * @param parentId
     * @param roleId
     * @return
     * @throws Exception
     */
    @ResponseBody
    @PostMapping("/loadCheckMenuInfo")
    @RequiresPermissions(value = {"角色管理"})
    public String loadCheckMenuInfo(Integer parentId, Integer roleId) throws Exception {
        List<Menu> menuList = menuService.selectMenusByRoleId(roleId);// 根据角色查询所有权限菜单信息
        //移除所有没有pid的menuid
        Iterator<Menu> it = menuList.iterator();
        while (it.hasNext()) {
            Menu tmenu = it.next();
            if (tmenu.getpId() == null) {
                it.remove();
            }
        }
        List<Integer> menuIdList = new LinkedList<Integer>();
        for (Menu menu : menuList) {
            menuIdList.add(menu.getId());
        }
        String json = getAllCheckedMenuByParentId(parentId, menuIdList).toString();
        //System.out.println(json);
        return json;
    }

    /**
     * 根据父节点ID和权限菜单ID集合获取复选框菜单节点
     *
     * @param parentId
     * @param menuIdList
     * @return
     */
    private JsonArray getAllCheckedMenuByParentId(Integer parentId, List<Integer> menuIdList) {
        JsonArray jsonArray = this.getCheckedMenuByParentId(parentId, menuIdList);
        for (int i = 0; i < jsonArray.size(); i++) {
            JsonObject jsonObject = (JsonObject) jsonArray.get(i);
            //判断该节点下时候还有子节点
            Example example=new Example(Menu.class);
            example.or().andEqualTo("pId",jsonObject.get("id").getAsString());
            //if ("open".equals(jsonObject.get("state").getAsString())) {
            if (menuService.selectCountByExample(example)==0) {
                continue;
            } else {
                jsonObject.add("children", getAllCheckedMenuByParentId(jsonObject.get("id").getAsInt(), menuIdList));
            }
        }
        return jsonArray;
    }

    /**
     * 根据父节点ID和权限菜单ID集合获取复选框菜单节点
     *
     * @param parentId
     * @param menuIdList
     * @return
     */
    private JsonArray getCheckedMenuByParentId(Integer parentId, List<Integer> menuIdList) {
        Example tmenuExample = new Example(Menu.class);
        tmenuExample.or().andEqualTo("pId",parentId);
        List<Menu> menuList = menuService.selectByExample(tmenuExample);
        JsonArray jsonArray = new JsonArray();
        for (Menu menu : menuList) {
            JsonObject jsonObject = new JsonObject();
            Integer menuId = menu.getId();
            jsonObject.addProperty("id", menuId); // 节点id
            jsonObject.addProperty("name", menu.getName()); // 节点名称
            //判断该节点下时候还有子节点
            Example example=new Example(Menu.class);
            example.or().andEqualTo("pId",jsonObject.get("id").getAsString());
            //if (menu.getState() == 1) {
            if (menuService.selectCountByExample(example)==0) {
                jsonObject.addProperty("open", "true"); // 无子节点
            } else {
                jsonObject.addProperty("open", "false"); // 有子节点
            }
            if (menuIdList.contains(menuId)) {
                jsonObject.addProperty("checked", true);
            }
            jsonArray.add(jsonObject);
        }
        return jsonArray;
    }

    /**
     * 保存角色权限设置
     *
     * @param menuIds
     * @param roleId
     * @return
     * @throws Exception
     */
    @ResponseBody
    @RequestMapping("/saveMenuSet")
    @RequiresPermissions(value = {"角色管理"})
    public ResponseMessage saveMenuSet(String menuIds, Integer roleId) throws Exception {

        if (StringUtils.isNotEmpty(menuIds)) {
            //先根据roleid查询出原有的对应的所有menuid集合
            List<Menu> menuList = menuService.selectMenusByRoleId(roleId);
            //移除所有没有pid的menuid
            Iterator<Menu> it = menuList.iterator();
            while (it.hasNext()) {
                Menu tmenu = it.next();
                if (tmenu.getpId() == null) {
                    it.remove();
                }
            }
            List<Integer> menuIdList = new LinkedList<Integer>();
            for (Menu menu : menuList) {
                menuIdList.add(menu.getId());
            }

            if(menuIdList!=null&&menuIdList.size()>0){
                Example roleMenuExample = new Example(Rolemenu.class);
                roleMenuExample.or().andEqualTo("roleId",roleId).andIn("menuId",menuIdList);
                roleMenuService.deleteByExample(roleMenuExample);
            }

            String idsStr[] = menuIds.split(",");
            for (int i = 0; i < idsStr.length; i++) { // 然后添加所有角色权限关联实体
                Rolemenu roleMenu = new Rolemenu();
                roleMenu.setRoleId(roleId);
                roleMenu.setMenuId(Integer.parseInt(idsStr[i]));
                roleMenuService.saveNotNull(roleMenu);
            }
        }else{
            return new ResponseMessage(ResponseMessage.PARAMETER_ERROR, "操作失败，未获取选中记录，请重新选择");
        }
        return ResponseMessage.initializeSuccessMessage(null);
    }




}
