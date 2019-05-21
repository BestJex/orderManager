package com.manager;

import org.apache.shiro.crypto.hash.SimpleHash;
import org.apache.shiro.util.ByteSource;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

@RunWith(SpringRunner.class)
@SpringBootTest
public class ManagerApplicationTests {

	@Test
	public void contextLoads() {
	}

	@Test
	public void getShiroSaltPwd() {
		String userName = "marry";
		String password = "123456";
		// 将用户名作为盐值
		ByteSource salt = ByteSource.Util.bytes(userName);
		String pwd = new SimpleHash("MD5", password, salt, 1024).toHex();
		System.out.println(pwd);
		// System.out.println(038bdaf98f2037b31f1e75b5b4c9b26e);
	}

}
