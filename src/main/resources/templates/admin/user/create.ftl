<#include "../../layout/layout.ftl"/>
<@Head title="用户添加"></@Head>
<@Body>
<div class="childrenBody">
    <form class="layui-form" style="width: 350px;">
        <div class="layui-form-item">
            <label class="layui-form-label">用户名</label>
            <div class="layui-input-block">
                <input type="text" id="userName" name="userName" lay-verify="userName" autocomplete="off" placeholder="请输入用户名" class="layui-input">
            </div>
        </div>
        <div class="layui-form-item password">
            <label class="layui-form-label">密码</label>
            <div class="layui-input-block">
                <input type="text" id="password" name="password" lay-verify="password" autocomplete="off" placeholder="请输入密码" class="layui-input">
            </div>
        </div>
        <div class="layui-form-item">
            <label class="layui-form-label">真实姓名</label>
            <div class="layui-input-block">
                <input type="text" id="trueName" name="trueName" autocomplete="off" placeholder="请输入真实姓名" class="layui-input">
            </div>
        </div>
        <div class="layui-form-item">
            <label class="layui-form-label">备注信息</label>
            <div class="layui-input-block">
                <input type="text" id="remark" name="remark" autocomplete="off" placeholder="请输入备注信息" class="layui-input">
            </div>
        </div>
        <div class="layui-form-item" style="padding-top: 50px">
            <div class="layui-input-block">
                <button class="layui-btn" lay-submit="" lay-filter="addSubmit">立即提交</button>
                <button id="reset" type="reset" class="layui-btn layui-btn-primary">重置</button>
            </div>
        </div>
    </form>
</div>

<script>
    layui.use(['layer','form','layedit','table'], function(){
        var layer = layui.layer;
        var layedit = layui.layedit;
        var form = layui.form;

        $("#reset").click();//重置表单(新建时在进入表单前要重置一下表单的内容，不然表单打开后会显示上一次的表单的内容。这里调用表单中重置按钮的点击方法来重置)
        //创建一个编辑器
        var editIndex = layedit.build('LAY_demo_editor');
        //自定义验证规则
        form.verify({
            userName: function(value) {
                if(value.length < 3) {
                    return '用户名至少得3个字符';
                }
            },
            password: [/(.+){6,12}$/, '密码必须6到12位'],
            content: function(value) {
                layedit.sync(editIndex);
            }
        });


        //监听提交
        form.on('submit(addSubmit)', function(data) {

            $.ajax({
                type: "POST",
                url:"admin/user/add",
                data: data.field,
                async: false,
                error: function(request) {
                    layer.alert("与服务器连接失败/(ㄒoㄒ)/~~");
                },
                success: function(res) {
                    if(res.code == 0){
                        layer.alert("操作成功", {icon: 6}, function (index) {
                            layer.close(index);
                            window.parent.location.reload();
                        })
                    } else {
                        layer.alert(res.msg);
                    }
                }
            });
            return false;//防止表单提交后跳转
        });
    })

</script>
</@Body>