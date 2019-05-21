package com.manager.realm;

import com.manager.entity.Role;
import com.manager.entity.Menu;
import com.manager.entity.User;
import com.manager.mapper.MenuMapper;
import com.manager.mapper.RoleMapper;
import com.manager.mapper.UserMapper;
import com.manager.mapper.UserroleMapper;
import org.apache.shiro.SecurityUtils;
import org.apache.shiro.authc.AuthenticationException;
import org.apache.shiro.authc.AuthenticationInfo;
import org.apache.shiro.authc.AuthenticationToken;
import org.apache.shiro.authc.SimpleAuthenticationInfo;
import org.apache.shiro.authz.AuthorizationInfo;
import org.apache.shiro.authz.SimpleAuthorizationInfo;
import org.apache.shiro.realm.AuthorizingRealm;
import org.apache.shiro.subject.PrincipalCollection;
import org.apache.shiro.util.ByteSource;
import tk.mybatis.mapper.entity.Example;

import javax.annotation.Resource;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * 自定义Realm
 * @author manager
 *
 */
public class MyRealm extends AuthorizingRealm{

	@Resource
	private UserMapper userMapper;
	
	@Resource
	private RoleMapper roleMapper;

	@Resource
	private UserroleMapper userroleMapper;
	
	@Resource
	private MenuMapper menuMapper;

	private SimpleAuthenticationInfo authInfo = null;

	/**
	 * 授权
	 */
	@Override
	protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection principals) {
		String userName=(String) SecurityUtils.getSubject().getPrincipal();

		//User user=userRepository.findByUserName(userName);
		//根据用户名查询出用户记录
		Example tuserExample=new Example(User.class);
		tuserExample.or().andEqualTo("userName",userName);
		User user=userMapper.selectByExample(tuserExample).get(0);


		SimpleAuthorizationInfo info=new SimpleAuthorizationInfo();

		//List<Role> roleList=roleRepository.findByUserId(user.getId());
		List<Role> roleList = roleMapper.selectRolesByUserId(user.getId());

		Set<String> roles=new HashSet<String>();
		if(roleList.size()>0){
			for(Role role:roleList){
				roles.add(role.getName());
				//List<Menu> menuList=menuRepository.findByRoleId(role.getId());
				//根据角色id查询所有资源
				List<Menu> menuList=menuMapper.selectMenusByRoleId(role.getId());
				for(Menu menu:menuList){
					info.addStringPermission(menu.getName()); // 添加权限
				}
			}
		}
		info.setRoles(roles);
		return info;
	}

	/**
	 * 权限认证
				*/
		@Override
		protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken token) throws AuthenticationException {
			String userName = (String)token.getPrincipal();
			Example tuserExample=new Example(User.class);

			// 查询数据库，是否查询到用户名和密码的用户
			tuserExample.or().andEqualTo("userName",userName);
			User user=userMapper.selectByExample(tuserExample).get(0);
			if(user!=null){

				// 获取盐值，即用户名
				ByteSource salt = ByteSource.Util.bytes(userName);
				String realmName = this.getName();

				  authInfo = new SimpleAuthenticationInfo(user.getUserName(),user.getPassword(), salt, realmName);
			}else{
				// 如果没有查询到，抛出一个异常
				throw new AuthenticationException();
			}
			return authInfo;
	}

}
