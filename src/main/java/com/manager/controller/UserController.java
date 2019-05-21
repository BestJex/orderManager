package com.manager.controller;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.manager.entity.Menu;
import com.manager.entity.Role;
import com.manager.entity.User;
import com.manager.service.MenuService;
import com.manager.service.RoleService;
import com.manager.service.UserService;
import com.manager.util.ResponseMessage;
import com.manager.util.ShiroUtil;
import org.apache.commons.lang3.StringUtils;
import org.apache.shiro.SecurityUtils;
import org.apache.shiro.authc.UsernamePasswordToken;
import org.apache.shiro.authz.annotation.RequiresPermissions;
import org.apache.shiro.crypto.hash.SimpleHash;
import org.apache.shiro.subject.Subject;
import org.apache.shiro.util.ByteSource;
import org.springframework.stereotype.Controller;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import tk.mybatis.mapper.entity.Example;

import javax.annotation.Resource;
import javax.servlet.http.HttpSession;
import javax.validation.Valid;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;


@Controller
@RequestMapping("/user")
public class UserController {

	@Resource
	private RoleService roleService;
	
	@Resource
	private UserService userService;
	
	@Resource
	private MenuService menuService;
	
	/*@Resource
	private LogService logService;*/
	
	/**
     * 用户登录
     * @param user
     * @return
     */
    @ResponseBody
    @PostMapping("/login")
    public Map<String,Object> login(String imageCode, @Valid User user, BindingResult bindingResult, HttpSession session){
    	Map<String,Object> map=new HashMap<String,Object>();
    	if(StringUtils.isEmpty(imageCode)){
    		map.put("success", false);
    		map.put("errorInfo", "请输入验证码！");
    		return map;
    	}
    	if(!session.getAttribute("checkcode").equals(imageCode)){
    		map.put("success", false);
    		map.put("errorInfo", "验证码输入错误！");
    		return map;
    	}
    	if(bindingResult.hasErrors()){
    		map.put("success", false);
    		map.put("errorInfo", bindingResult.getFieldError().getDefaultMessage());
    		return map;
    	}
		Subject subject=SecurityUtils.getSubject();
		UsernamePasswordToken token = new UsernamePasswordToken(user.getUserName(), user.getPassword());
		try{
			subject.login(token); // 登录认证
			String userName = (String) SecurityUtils.getSubject().getPrincipal();
			//User currentUser = userService.findByUserName(userName);
			Example tuserExample=new Example(User.class);
			tuserExample.or().andEqualTo("userName",userName);
			User currentUser=userService.selectByExample(tuserExample).get(0);
			session.setAttribute("currentUser", currentUser);
			//List<Role> roleList=roleService.findByUserId(currentUser.getId());
			List<Role> roleList = roleService.selectRolesByUserId(currentUser.getId());
			map.put("roleList", roleList);
			map.put("roleSize", roleList.size());
			map.put("success", true);
			//logService.save(new Log(Log.LOGIN_ACTION,"用户登录")); // 写入日志
			return map;
		}catch(Exception e){
			e.printStackTrace();
			map.put("success", false);
			map.put("errorInfo", "用户名或者密码错误！");
			return map;
		}
    }



	/**
	 * 保存角色信息
	 * @param roleId
	 * @param session
	 * @return
	 * @throws Exception
	 */
	@ResponseBody
	@PostMapping("/saveRole")
	public Map<String,Object> saveRole(Integer roleId,HttpSession session)throws Exception{
		Map<String,Object> map=new HashMap<String,Object>();
		Role currentRole=roleService.selectByKey(roleId);
		session.setAttribute("currentRole", currentRole); // 保存当前角色信息

		putTmenuOneClassListIntoSession(session);

		map.put("success", true);
		return map;
	}


	/**
	 * 加载权限菜单
	 * @param session
	 * @return
	 * @throws Exception
	 * 这里传入的parentId是1
	 */
	@ResponseBody
	@GetMapping("/loadMenuInfo")
	public String loadMenuInfo(HttpSession session, Integer parentId)throws Exception{

		putTmenuOneClassListIntoSession(session);

		Role currentRole=(Role) session.getAttribute("currentRole");
		//根据当前用户的角色id和父节点id查询所有菜单及子集json
		String json=getAllMenuByParentId(parentId,currentRole.getId()).toString();
		//System.out.println(json);
		return json;
	}

	/**
	 * 获取根频道所有菜单信息
	 * @param parentId
	 * @param roleId
	 * @return
	 */
	private JsonObject getAllMenuByParentId(Integer parentId,Integer roleId){
		JsonObject resultObject=new JsonObject();
		JsonArray jsonArray=this.getMenuByParentId(parentId, roleId);//得到所有一级菜单
		for(int i=0;i<jsonArray.size();i++){
			JsonObject jsonObject=(JsonObject) jsonArray.get(i);
			//判断该节点下时候还有子节点
			Example example=new Example(Menu.class);
			example.or().andEqualTo("pId",jsonObject.get("id").getAsString());
			//if("true".equals(jsonObject.get("spread").getAsString())){
			if (menuService.selectCountByExample(example)==0) {
				continue;
			}else{
				//由于后台模板的规定，一级菜单以title最为json的key
				resultObject.add(jsonObject.get("title").getAsString(), getAllMenuJsonArrayByParentId(jsonObject.get("id").getAsInt(),roleId));
			}
		}
		return resultObject;
	}



	//获取根频道下子频道菜单列表集合
	private JsonArray getAllMenuJsonArrayByParentId(Integer parentId,Integer roleId){
		JsonArray jsonArray=this.getMenuByParentId(parentId, roleId);
		for(int i=0;i<jsonArray.size();i++){
			JsonObject jsonObject=(JsonObject) jsonArray.get(i);
			//判断该节点下是否还有子节点
			Example example=new Example(Menu.class);
			example.or().andEqualTo("pId",jsonObject.get("id").getAsString());
			//if("true".equals(jsonObject.get("spread").getAsString())){
			if (menuService.selectCountByExample(example)==0) {
				continue;
			}else{
				//二级或三级菜单
				jsonObject.add("children", getAllMenuJsonArrayByParentId(jsonObject.get("id").getAsInt(),roleId));
			}
		}
		return jsonArray;
	}




	/**
	 * 根据父节点和用户角色id查询菜单
	 * @param parentId
	 * @param roleId
	 * @return
	 */
	private JsonArray getMenuByParentId(Integer parentId,Integer roleId){
		//List<Menu> menuList=menuService.findByParentIdAndRoleId(parentId, roleId);
		HashMap<String,Object> paraMap=new HashMap<String,Object>();
		paraMap.put("pid",parentId);
		paraMap.put("roleid",roleId);
		List<Menu> menuList=menuService.selectByParentIdAndRoleId(paraMap);
		JsonArray jsonArray=new JsonArray();
		for(Menu menu:menuList){
			JsonObject jsonObject=new JsonObject();
			jsonObject.addProperty("id", menu.getId()); // 节点id
			jsonObject.addProperty("title", menu.getName()); // 节点名称
			jsonObject.addProperty("spread", false); // 不展开
			jsonObject.addProperty("icon", menu.getIcon());
			if(StringUtils.isNotEmpty(menu.getUrl())){
				jsonObject.addProperty("href", menu.getUrl()); // 菜单请求地址
			}
			jsonArray.add(jsonObject);

		}
		return jsonArray;
	}




public void putTmenuOneClassListIntoSession(HttpSession session){
	//用来在welcome.ftl中获取主菜单列表
	Example example=new Example(Menu.class);
	example.or().andEqualTo("pId",1);
	List<Menu> tmenuOneClassList=menuService.selectByExample(example);
	session.setAttribute("tmenuOneClassList", tmenuOneClassList);
}


	/**
	 * 安全退出
	 *
	 * @return
	 * @throws Exception*/

	@GetMapping("/logout")
	@RequiresPermissions(value = {"安全退出"})
	public String logout() throws Exception {
//		logService.save(new Log(Log.LOGOUT_ACTION,"用户注销"));
		SecurityUtils.getSubject().logout();
		return "redirect:/tologin";
	}


	//跳转到修改密码页面
	@RequestMapping("/updatePwd/index")
	@RequiresPermissions(value = {"修改密码"})
	public String toUpdatePassword() {
		return "updatePwd";
	}



	//修改密码
	@ResponseBody
	@PostMapping("/updatePwd")
	@RequiresPermissions(value = {"修改密码"})
	public ResponseMessage updatePassword(User user) throws Exception {
		try {

			if(user==null){
				return new ResponseMessage(ResponseMessage.PARAMETER_ERROR, "设置失败，缺乏字段信息");
			}else{
				if(user.getId()!=null
						&&user.getId().intValue()!=0
						&& StringUtils.isNotEmpty(user.getUserName())
						&& StringUtils.isNotEmpty(user.getOldPassword())
						&& StringUtils.isNotEmpty(user.getPassword())){
					Example userExample=new Example(User.class);
					Example.Criteria criteria=userExample.or();
					criteria.andEqualTo("id",user.getId())
							.andEqualTo("userName",user.getUserName())
							.andEqualTo("password",ShiroUtil.getSaltPwd(user.getUserName(),user.getOldPassword()));
					List<User> userList=userService.selectByExample(userExample);
					if(userList==null||userList.size()==0){
						return new ResponseMessage(ResponseMessage.PARAMETER_ERROR, "用户名或密码错误");
					}else{
						User newEntity=userList.get(0);
						newEntity.setPassword(ShiroUtil.getSaltPwd(user.getUserName(),user.getPassword()));
						userService.updateNotNull(newEntity);
					}
				}else{
					return new ResponseMessage(ResponseMessage.PARAMETER_ERROR, "设置失败，缺乏字段信息");
				}
			}
			return ResponseMessage.initializeSuccessMessage(null);
		} catch (Exception e) {
			e.printStackTrace();
			return new ResponseMessage(ResponseMessage.SYSTEM_ERROR, "密码修改失败，系统异常");
		}
	}



}
