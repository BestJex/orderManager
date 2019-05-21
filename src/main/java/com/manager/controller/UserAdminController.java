package com.manager.controller;

import com.github.pagehelper.PageHelper;
import com.manager.entity.Role;
import com.manager.entity.User;
import com.manager.entity.Userrole;
import com.manager.entity.converter.UserConverter;
import com.manager.model.PageRusult;
import com.manager.service.RoleService;
import com.manager.service.UserService;
import com.manager.service.UserroleService;
import com.manager.service.dto.user.*;
import com.manager.util.ResponseMessage;
import org.apache.commons.lang3.StringUtils;
import org.apache.shiro.authz.annotation.RequiresPermissions;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.ModelAndView;
import tk.mybatis.mapper.entity.Example;

import javax.annotation.Resource;
import java.util.Iterator;
import java.util.List;

/**
 * 后台管理用户Controller
 * @author manager
 */
@Controller
@RequestMapping("/admin/user")
public class UserAdminController {

    @Resource
    private UserService userService;

    @Resource
    private RoleService roleService;

    @Resource
    private UserroleService userRoleService;


    @RequestMapping(value = "/index", method = RequestMethod.GET)
    @RequiresPermissions(value = {"用户管理"})
    public ModelAndView index() {
        ModelAndView mv = new ModelAndView();
        mv.setViewName( "admin/user/index");
        return mv;
    }

    @RequestMapping(value = "/create", method = RequestMethod.GET)
    @RequiresPermissions(value = {"用户管理"})
    public ModelAndView create() {
        ModelAndView mv = new ModelAndView();
        mv.setViewName("admin/user/create");
        return mv;
    }


    /**
     * 分页查询用户信息
     */
    @ResponseBody
    @RequestMapping(value = "/list")
    @RequiresPermissions(value = {"用户管理"})
    public ResponseMessage list(UserListRequest request) throws Exception {

        Example userExample = new Example(User.class);
        //userExample.or().andIdNotEqualTo(1L);
        Example.Criteria criteria = userExample.or();
       /* criteria.andNotEqualTo("userName","admin");*/

        if (StringUtils.isNotEmpty(request.getUserName())) {
            criteria.andEqualTo("userName",request.getUserName());
        }

        PageHelper.startPage(request.getPage(), request.getLimit());
        List<User> userList = userService.selectByExample(userExample);
        PageRusult<User> pageRusult =new PageRusult<User>(userList);

        for (User u : userList) {
            List<Role> roleList = roleService.selectRolesByUserId(u.getId());
            StringBuffer sb = new StringBuffer();
            for (Role r : roleList) {
                sb.append("," + r.getName());
            }
            u.setRoles(sb.toString().replaceFirst(",", ""));
        }

        UserListResponse data = new UserListResponse();
        data.setCount((int)pageRusult.getTotal());
       data.setItems(userList);

       return ResponseMessage.initializeSuccessMessage(data);
    }

    @ResponseBody
    @RequestMapping(value = "/add", method = RequestMethod.POST)
    @RequiresPermissions(value = {"用户管理"})
    public ResponseMessage addUser(UserAddRequest request) {
        try {
            //首先判断用户名是否可用
            Example userExample = new Example(User.class);
            userExample.or().andEqualTo("userName",request.getUserName());
            List<User> userlist = userService.selectByExample(userExample);
            if (userlist != null && userlist.size() > 0) {
                return new ResponseMessage(ResponseMessage.PARAMETER_ERROR,"当前用户名已存在");
            }
            User user = new User();
            user = UserConverter.addRequestToUser(user,request);
            userService.saveNotNull(user);
            return ResponseMessage.initializeSuccessMessage(null);
        } catch (Exception e) {
            e.printStackTrace();
           return new ResponseMessage(ResponseMessage.SYSTEM_ERROR,"操作失败，系统异常");
        }
    }

    @ResponseBody
    @RequestMapping(value = "/edit",method = RequestMethod.POST)
    @RequiresPermissions(value = {"用户管理"})
    public ResponseMessage editUser(UserEditRequest request) {
        try {
                User user = userService.selectByKey(request.getId());
                if(user == null){
                    return  new ResponseMessage(ResponseMessage.PARAMETER_ERROR, "当前用户名不存在");
                }else{
                    user = UserConverter.editRequestToUser(user,request);
                    userService.updateNotNull(user);
                }
            return ResponseMessage.initializeSuccessMessage(null);
        } catch (Exception e) {
            return new ResponseMessage(ResponseMessage.SYSTEM_ERROR,"操作失败，系统异常");
        }
    }



    @ResponseBody
    @RequestMapping(value = "/delete")
    @RequiresPermissions(value = {"用户管理"})
    public ResponseMessage deleteuser(@RequestParam("id") Integer id) {
        try {

            User user=userService.selectByKey(id);
            if(user == null){
                return new ResponseMessage(ResponseMessage.PARAMETER_ERROR,"删除失败,无法找到该记录");
            }else{
                //还需删除用户角色中间表
                Example userroleexample=new Example(Userrole.class);
                userroleexample.or().andEqualTo("userId",user.getId());
                userRoleService.deleteByExample(userroleexample);userService.delete(user.getId());

            }
            return ResponseMessage.initializeSuccessMessage(null);
        } catch (Exception e) {
            return new ResponseMessage(ResponseMessage.SYSTEM_ERROR, "删除失败，系统异常");
        }
    }




    @ResponseBody
    @RequestMapping(value = "/info",method = RequestMethod.POST)
    @RequiresPermissions(value = {"用户管理"})
    public ResponseMessage getUserById(@RequestParam("id") Integer id) {
        try {
                User user = userService.selectByKey(id);
                if(user == null){
                    return new ResponseMessage(ResponseMessage.PARAMETER_ERROR,"无法找到该记录");
                }

            List<Role> roleList = roleService.selectRolesByUserId(user.getId());
            StringBuffer sb = new StringBuffer();
            for (Role r : roleList) {
                sb.append("," + r.getName());
            }
            user.setRoles(sb.toString().replaceFirst(",", ""));


            //所有角色
            Example troleExample=new Example(Role.class);
            //troleExample.or().andNameNotEqualTo("管理员");
            List<Role> allrolelist=roleService.selectByExample(troleExample);

            UserInfoResponse data = new UserInfoResponse();
            data.setRoleList(roleList); //用户拥有的所有角色

            Iterator<Role> it = allrolelist.iterator();
            while (it.hasNext()) {
                Role temp = it.next();
                for(Role e2:roleList){
                    if(temp.getId().compareTo(e2.getId())==0){
                        it.remove();
                    }
                }
            }

            List<Role> notinrolelist = allrolelist;

            data.setNotInRolelist(notinrolelist);//用户不拥有的角色

            data.setUser(user);
            return ResponseMessage.initializeSuccessMessage(data);
        } catch (Exception e) {
            return new ResponseMessage(ResponseMessage.SYSTEM_ERROR,"获取失败，系统异常");
        }
    }



    //设置用户角色
    @ResponseBody
    @RequestMapping(value = "/saveRoleSet")
    @RequiresPermissions(value = {"用户管理"})
    public ResponseMessage saveRoleSet(Integer[] role,Integer id) {
        try {
            // 根据用户id删除所有用户角色关联实体
            Example userroleexample=new Example(Userrole.class);
            userroleexample.or().andEqualTo("userId",id);
            userRoleService.deleteByExample(userroleexample);

            if(role!=null && role.length>0){
                for(Integer roleid:role){
                    Userrole userrole=new Userrole();
                    userrole.setRoleId(roleid);
                    userrole.setUserId(id);
                    userRoleService.saveNotNull(userrole);
                }
            }

            return ResponseMessage.initializeSuccessMessage(null);
        } catch (Exception e) {
            return new ResponseMessage(ResponseMessage.SYSTEM_ERROR, "设置失败，系统异常");
        }
    }

}
