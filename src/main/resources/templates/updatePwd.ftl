<#include "layout/layout.ftl"/>
<@Head title="修改密码"></@Head>
<@Body>
<div class="layui-card" style="width: 500px;border:1px solid #BFBFBF;box-shadow:0px 0px  10px 5px #aaa;margin: 50px 50px">
    <div class="layui-card-header" style="border-bottom: 1px solid #ffffff;font-size: 15px">修改密码</div>
    <hr class="layui-bg-green">
    <div class="layui-card-body">
        <form class="layui-form" action="" id="formid" style="margin-top: 10px">
            <input type="hidden" name="id" id="userId" value=""/>
            <div class="layui-form-item">
                <label class="layui-form-label">用户名</label>
                <div class="layui-input-inline"">
                <input type="text" name="userName" readonly value="${currentUser.userName!}" lay-verify="required" placeholder="请输入用户名" autocomplete="off" class="layui-input">
            </div>
    </div>
    <div class="layui-form-item">
        <label class="layui-form-label">旧密码</label>
        <div class="layui-input-inline">
            <input type="password" name="oldPassword" required lay-verify="required" placeholder="请输入旧密码" autocomplete="off" class="layui-input">
        </div>
       <#-- <div class="layui-form-mid layui-word-aux">旧密码</div>-->
    </div>
    <div class="layui-form-item">
        <label class="layui-form-label">新密码</label>
        <div class="layui-input-inline">
            <input type="password" name="password" required lay-verify="required" placeholder="请输入新密码" autocomplete="off" class="layui-input">
        </div>
      <#--  <div class="layui-form-mid layui-word-aux">新密码</div>-->
    </div>

    <div class="layui-form-item">
        <div class="layui-input-block">
            <button class="layui-btn" lay-submit lay-filter="submitButton">立即提交</button>
            <button type="reset" class="layui-btn layui-btn-primary">重置</button>
        </div>
    </div>
    </form>
</div>
</div>

<script>
    //一般直接写在一个js文件中
    layui.use(['layer','form','table'], function(){
        var layer = layui.layer,
            form = layui.form,
            $ = layui.$


        //监听表单提交事件
        form.on('submit(submitButton)', function (data) {
            $("#userId").val(${currentUser.id!});
            $.ajax({
                type: "POST",
                url:"user/updatePwd",
                data:$("#formid").serialize(),
                async: false,
                error: function(request) {
                    layer.alert("与服务器连接失败/(ㄒoㄒ)/~~");
                },
                success: function(res) {
                    if(res.code == 0){
                        layer.alert("操作成功", {icon: 6}, function (index) {
                            layer.close(index);
                            window.location.href="${basePath!}/user/logout";
                        })
                        return false;
                    } else {
                        layer.alert(res.msg);
                        return false;
                    }
                }
            });

            return false;//防止表单提交
        });



    });
</script>
</@Body>