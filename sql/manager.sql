/*
SQLyog 企业版 - MySQL GUI v8.14 
MySQL - 5.7.17-log : Database - manager
*********************************************************************
*/


CREATE DATABASE /*!32312 IF NOT EXISTS*/`manager` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `manager`;

/*Table structure for table `menu` */

DROP TABLE IF EXISTS `menu`;

CREATE TABLE `menu` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `icon` varchar(100) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `state` int(11) DEFAULT NULL,
  `url` varchar(200) DEFAULT NULL,
  `p_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1705032705 DEFAULT CHARSET=utf8;

/*Data for the table `menu` */

insert  into `menu`(`id`,`icon`,`name`,`state`,`url`,`p_id`) values (1,'&#xe614;','系统菜单',1,NULL,-1),(60,'&#xe631;','系统管理',1,NULL,1),(6000,'&#xe671;','菜单管理',2,'admin/menu/index',60),(6010,'&#xe613;','角色管理',2,'admin/role/index',60),(6020,'&#xe612;','用户管理',2,'admin/user/index',60),(6030,'&#xe62a;','订单管理',2,'admin/order/index',60),(6040,'&#xe631;','sql监控',2,'druid/index.html',60),(6050,'&#xe614;','修改密码',2,'user/updatePwd/index',60),(6060,'&#xe65c;','安全退出',2,'user/logout',60);

/*Table structure for table `role` */

DROP TABLE IF EXISTS `role`;

CREATE TABLE `role` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `remark` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8;

/*Data for the table `role` */

insert  into `role`(`id`,`name`,`remark`) values (1,'管理员','系统管理员 最高权限'),(2,'主管','主管'),(3,'采购员','采购员'),(4,'销售经理','销售经理'),(5,'仓库管理员','仓库管理员');

/*Table structure for table `role_menu` */

DROP TABLE IF EXISTS `role_menu`;

CREATE TABLE `role_menu` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `menu_id` int(11) DEFAULT NULL,
  `role_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=289 DEFAULT CHARSET=utf8;

/*Data for the table `role_menu` */

insert  into `role_menu`(`id`,`menu_id`,`role_id`) values (36,10,2),(42,1,2),(45,1,4),(48,1,5),(55,1,9),(65,1,7),(66,10,7),(126,60,15),(127,6010,15),(128,6020,15),(129,6030,15),(130,6040,15),(131,6050,15),(248,2000,1),(259,100000,1),(278,10,1),(279,1000,1),(280,60,1),(281,6000,1),(282,6010,1),(283,6020,1),(284,6030,1),(285,6040,1),(286,6050,1),(287,61,1),(288,6060,1);

/*Table structure for table `user` */

DROP TABLE IF EXISTS `user`;

CREATE TABLE `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `password` varchar(50) DEFAULT NULL,
  `true_name` varchar(50) DEFAULT NULL,
  `user_name` varchar(50) DEFAULT NULL,
  `remark` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;

/*Data for the table `user` */

insert  into `user`(`id`,`password`,`true_name`,`user_name`,`remark`) values (1,'038bdaf98f2037b31f1e75b5b4c9b26e','admin','admin','密码：123456'),(2,'d71c5a8dac1256f42a90a78227e40cfa','杰克','jack','密码：123456'),(3,'e5f18d5cfbe2e51a7fffa3a4232bab51','玛丽','marry','密码：123456');

/*Table structure for table `user_role` */

DROP TABLE IF EXISTS `user_role`;

CREATE TABLE `user_role` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8;

/*Data for the table `user_role` */

insert  into `user_role`(`id`,`role_id`,`user_id`) values (1,1,1),(19,2,2),(20,4,2),(21,5,2),(28,2,3),(29,4,3),(30,5,3),(31,7,3),(49,15,5),(50,1,5);

/*Data for the table `orders` */

DROP TABLE IF EXISTS `orders`;

create table orders(
id int(11) not null auto_increment comment '主键',
import_no varchar(50) not null comment '导入编号',
task_no varchar(50) not null  comment '任务编号',
order_no varchar(50) not null comment '订单编号',
shop varchar(50) not null comment '店铺名',
taobao varchar(50) not null comment '淘宝账号',
en_price int(11) not null comment '录入价格。单位:分',
real_price int(11) not null comment '实际价格。单位:分',
status tinyint(4) not null default 1 comment '订单状态：1、代拍下，2、已拍下，3、已付款，4、其他',
sign_status tinyint(4) not null default 1 comment '标状态：1、等待标记，2、标记成功，3、标记失败，4、未订购应用',
end_time datetime comment '截止时间',
primary key(id)
)comment='订单列表';