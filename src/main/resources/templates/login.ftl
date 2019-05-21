<!DOCTYPE html>
<html lang="zh-cn">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
	<title>登录-后台管理系统</title>
    <script src="${basePath!}/static/js/jquery.min.js" type="text/javascript"></script>
	<link rel="icon" href="${basePath!}/static/img/logo.png">
    <script src="${basePath!}/static/layui/layui.js" type="text/javascript"></script>
    <link href="${basePath!}/static/layui/css/layui.css" type="text/css" media="screen" rel="stylesheet"/>
    <link href="${basePath!}/static/css/login/font-awesome.css" rel="stylesheet">
    <link href="${basePath!}/static/css/login/login.css" rel="stylesheet">
    <link href="${basePath!}/static/css/login/normalize.css" rel="stylesheet">
    <link href="${basePath!}/static/css/login/demo.css" rel="stylesheet">
    <link href="${basePath!}/static/css/login/component.css" rel="stylesheet">
</head>
<body class="kit-theme">
<div class="container demo-1">
    <div class="content">
        <div id="large-header" class="large-header" style="height: 298px;">
            <canvas id="demo-canvas" width="1920" height="298"></canvas>
            <div class="kit-login-box">
                <header>
                    <h1>后台管理系统</h1>
                </header>
                <div class="kit-login-main">
                    <form class="layui-form" method="post">
                        <div class="layui-form-item">
                            <label class="kit-login-icon">
                                <i class="layui-icon"></i>
                            </label>
                            <input type="text" id="userName" name="userName" lay-verify="required" autocomplete="off" placeholder="请输入用户名" class="layui-input">
                        </div>
                        <div class="layui-form-item">
                            <label class="kit-login-icon">
                                <i class="layui-icon"></i>
                            </label>
                            <input type="password" id="password" name="password" lay-verify="required" autocomplete="off" placeholder="请输入密码" class="layui-input">
                        </div>
                        <div class="layui-form-item input-item"  id="imgCode">
                            <label class="kit-login-icon">
                                <i class="layui-icon"></i>
                            </label>
                            <input type="text" placeholder="请输入验证码" id="imageCode" name="imageCode"  autocomplete="off" id="code" class="layui-input">
                        <#--验证码通过接口获取-->
                            <span class="form-code" id="changeCode" style="position:absolute;right:2px; top:2px;">
                                           <img id="imgObj" title="看不清，换一张" src="${basePath!}/drawImage" onclick="changeImg()"/>
                                        </span>
                        </div>
                        <div class="layui-form-item">
                            <div class="kit-pull-right">
                                <button class="layui-btn layui-btn-primary" lay-filter="login" lay-submit>
                                    <i class="fa fa-sign-in" aria-hidden="true"></i> 登录
                                </button>
                            </div>
                            <div class="kit-clear"></div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
	<script type="text/javascript" src="${basePath!}/static/layui/layui.js"></script>
    <script src="${basePath!}/static/js/login/TweenLite.min.js"></script>
    <script src="${basePath!}/static/js/login/EasePack.min.js"></script>
    <script src="${basePath!}/static/js/login/rAF.js"></script>
    <script src="${basePath!}/static/js/login/demo-1.js"></script>
	<script type="text/javascript" src="${basePath!}/static/js/cache.js"></script>
    <script type="text/javascript" src="${basePath!}/static/js/verifyCode.js"></script>



    <script>
        layui.use(['jquery', 'layer', 'form'], function () {
            var layer = layui.layer,
                    $ = layui.jquery,
                    form = layui.form;

            //监听表单提交事件
            form.on('submit(login)', function (data) {

                $.post("${basePath!}/user/login", {
                    userName: $("#userName").val(),
                    password: $("#password").val(),
                    imageCode: $("#imageCode").val()
                }, function (result) {
                    if (result.success) {
                        if (result.roleSize == 1) {
                            var roleId = result.roleList[0].id;
                            $.post("${basePath!}/user/saveRole", {roleId: roleId}, function (result) {
                                if (result.success) {
                                    window.location.href = "${basePath!}/welcome";
                                }
                            });
                        } else {
                            $("#roleList").empty();
                            var roles = result.roleList;
                            for (var i = 0; i < roles.length; i++) {
                                if (i == 0) {
                                    $("#roleList").append("<input type='radio' checked=true  name='role' title='" + roles[i].name + "' value='" + roles[i].id + "'/>")

                                } else {
                                    $("#roleList").append("<input type='radio' name='role'  title='" + roles[i].name + "' value='" + roles[i].id + "'/>")
                                }
                                layui.form.render();//刷新所有表单的渲染效果
                            }

                            layer.open(
                                    {
                                        type: 1,
                                        title: '请选择一个角色登录系统',
                                        content: $("#light"),
                                        area: '500px',
                                        offset: 'auto',
                                       /* skin: 'layui-layer-molv',*/
                                        shade: [0.8, '#393D49']
                                    }
                            )

                        }
                    } else {
                        layer.alert(result.errorInfo);
                    }
                });


                return false;
            });


            //监听角色选择提交
            form.on('submit(choserolefilter)', function (data) {
                saveRole();
                return false;
            });

        });


        function saveRole() {
            var roleId = $("input[name='role']:checked").val();
            $.post("${basePath!}/user/saveRole", {roleId: roleId}, function (result) {
                if (result.success) {
                    window.location.href = "${basePath!}/welcome";
                }
            });
        }


    </script>


    <div id="light" hidden class="layui-fluid">

        <form class="layui-form" action="" style="padding: inherit;width: inherit;height: inherit;position: static;margin: auto;box-shadow: none">
            <div class="layui-form-item">
                <label class="layui-form-label">请选择角色</label>
                <div class="layui-input-block" id="roleList">
                </div>
            </div>
            <div class="layui-form-item">
                <div class="layui-input-block">
                    <button class="layui-btn" lay-submit lay-filter="choserolefilter">确定</button>
                </div>
            </div>
        </form>
    </div>
</body>

<style>
    canvas {
        position: absolute;
        z-index: -1;
    }

    .kit-login-box header h1 {
        line-height: normal;
    }

    .kit-login-box header {
        height: auto;
    }

    .content {
        position: relative;
    }

    .codrops-demos {
        position: absolute;
        bottom: 0;
        left: 40%;
        z-index: 10;
    }

    .codrops-demos a {
        border: 2px solid rgba(242, 242, 242, 0.41);
        color: rgba(255, 255, 255, 0.51);
    }

    .kit-pull-right button,
    .kit-login-main .layui-form-item input {
        background-color: transparent;
        color: white;
    }

    .kit-login-main .layui-form-item input::-webkit-input-placeholder {
        color: white;
    }

    .kit-login-main .layui-form-item input:-moz-placeholder {
        color: white;
    }

    .kit-login-main .layui-form-item input::-moz-placeholder {
        color: white;
    }

    .kit-login-main .layui-form-item input:-ms-input-placeholder {
        color: white;
    }

    .kit-pull-right button:hover {
        border-color: #009688;
        color: #009688
    }
</style>

</html>


<script type="text/javascript">
    /*session过期后登陆页面跳出iframe页面问题
    登陆页面增加javascript*/
    if (top.location !== self.location) {
        top.location = self.location;
    }
</script>