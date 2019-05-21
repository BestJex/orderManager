<#include "../../layout/layout.ftl"/>
<@Head title="用户管理"></@Head>
<@Body>
<blockquote class="layui-elem-quote">
    <button class="layui-btn"  onclick="admin_show('新建用户','${basePath}/admin/user/create',400,400)"><i class="layui-icon"></i>添加</button>
</blockquote>
<table class="layui-table" id="layui_table_id" lay-filter="dataTable" ></table>

<script type="text/html" id="bar">
    <a class="layui-btn layui-btn-xs" lay-event="edit">编辑</a>
    <a class="layui-btn layui-btn-danger layui-btn-xs" lay-event="del">删除</a>
    <a class="layui-btn layui-btn-warm layui-btn-xs" lay-event="setPermission">设置权限</a>
</script>

<#--带有 class="layui-fluid" 的容器中，那么宽度将不会固定，而是 100% 适应-->
<div id="addFormDiv" hidden="" class="layui-fluid" style="margin: 15px;">

</div>

<#--带有 class="layui-fluid" 的容器中，那么宽度将不会固定，而是 100% 适应-->
<div id="editFormDiv" hidden="" class="layui-fluid" style="margin: 15px;">
    <form class="layui-form" action="" id="editForm">
        <label hidden="true" id="editLabelId"></label>
        <input id="editId" name="id" value="" hidden/>
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
        <div class="layui-form-item">
            <div class="layui-input-block">
                <button class="layui-btn" lay-submit="" lay-filter="editSubmit">立即提交</button>
                <button id="editReset" type="reset" class="layui-btn layui-btn-primary">重置</button>
            </div>
        </div>

    </form>
</div>

<#--带有 class="layui-fluid" 的容器中，那么宽度将不会固定，而是 100% 适应-->
<div id="editRoleFormDiv" hidden="" class="layui-fluid" style="margin: 15px;">
    <form class="layui-form" action="" id="editRoleForm">
        <label hidden="true" id="editRoleLabelId"></label>
        <input id="editRoleId" name="id" value="" hidden />
        <div class="layui-form-item">
            <label class="layui-form-label">角色复选框</label>
            <div class="layui-input-block" id="checkboxlistid">
            </div>
        </div>
        <div class="layui-form-item">
            <div class="layui-input-block">
                <button class="layui-btn" lay-submit="" lay-filter="editRoleSubmit">立即提交</button>
                <button id="editRoleReset" type="reset" class="layui-btn layui-btn-primary">重置</button>
            </div>
        </div>
    </form>
</div>

<script>
var layerid;//当前弹层id;这个id可以定义多个，主要的目的是为了在回调函数关闭弹层时使用的

layui.use(['layer','form','table'], function(){
    var layer = layui.layer;
    var form = layui.form;

    var table = layui.table;
    table.render({
        id: "dataTable",//
        elem: '#layui_table_id',//指定表格元素
        url: 'admin/user/list',  //请求路径
        cellMinWidth: 20,//全局定义常规单元格的最小宽度，layui 2.2.1 新增
        even: true,   //隔行换色
        page: true, //开启分页
        limits: [20, 50, 100],  //每页条数的选择项，默认：[10,20,30,40,50,60,70,80,90]。
        limit: 20,//每页默认显示的数量
        method: 'get',  //提交方式
        cols: [[
            {
                field: 'id',
                hide : true
            },
            {
                field: 'userName', //json对应的key
                width: 200,
                title: '用户名',   //列名
                align: 'center',
                sort: false   // 默认为 false,true为开启排序
            },
            {
                field: 'trueName',
                title: '真实姓名',
                align: 'center'
            },
            {
                field: 'remark',
                title: '备注',
                align: 'center'
            },{
                field: 'roles',
                title: '拥有角色',
                align: 'center'
            },
            {fixed: 'right',  align: 'center',title:'操作', toolbar: '#bar', width:200}
        ]],
        parseData: function(res){
            data = res.data;
            return {
               /* "code": 0,  //必须状态为0*/
                "code": res.code,
                "count": data.count, //解析数据长度
                "data": data.items //解析数据列表
            };
        }
    });
    table.on('tool(dataTable)', function(obj){
        var data = obj.data;
        if(obj.event === 'edit'){
            doEdit(data);
        } else if(obj.event === 'del'){
            doDel(data);
        } else if(obj.event === 'setPermission'){
           setPermission(data)
        }
    });


    //监听提交
    form.on('submit(editSubmit)', function(data) {

        //为了防止form中的id值被重置后置空,将编辑的id存放在label中
        $("#editId").val($("#editLabelId").html());
        $("#editLabelId").html("");

        $.ajax({
            type: "POST",
            url:"admin/user/edit",
            data:$('#editForm').serialize(),
            async: false,
            error: function(request) {
                layer.alert("与服务器连接失败/(ㄒoㄒ)/~~");
            },
            success: function(res) {
                if(res.code == 0 ){
                    layer.alert("操作成功", {icon: 6}, function (index) {
                        //关闭当前frame
                        layer.close(index);
                        layer.close(layerid);
                        $("#editReset").click();//重置表单
                        window.location.reload()
                    })
                } else {
                    layer.alert(data.msg);
                }
            }
        });
        return false;//防止表单提交后跳转
    });

    //监听提交
    form.on('submit(editRoleSubmit)', function(data) {
        //为了防止form中的id值被重置后置空,将编辑的id存放在label中
        $("#editRoleId").val($("#editRoleLabelId").html() );
        $("#editRoleLabelId").html("");
        console.log( $("#editRoleId").val());

        $.ajax({
            type: "POST",
            url:"admin/user/saveRoleSet",
            data:$('#editRoleForm').serialize(),// 你的formid
            async: false,
            error: function(request) {
                layer.alert("与服务器连接失败/(ㄒoㄒ)/~~");
            },
            success: function(res) {
                if(res.code == 0){
                    layer.alert("设置成功", {icon: 6}, function (index) {
                        //关闭当前frame
                        layer.close(index);
                        layer.close(layerid);
                        $("#editRoleReset").click();//重置表单
                        window.location.reload()
                    })
                } else {
                    layer.alert(res.msg);
                }
            }
        });
        return false;
    });
})


function doEdit(data) {
    //请求后台，获取该记录的详细记录，并填充进表单
    $.ajax({
        type: "POST",
        url:"admin/user/info",
        data:{id:data.id},
        async: false,
        error: function(request) {
            layer.alert("与服务器连接失败/(ㄒoㄒ)/~~");
        },
        success: function(res) {
            if(res.code == 0){
                //向表单填充数据
                $("#editLabelId").html(data.id);//临时存放id，当提交时再去除赋值给input
                $("#trueName").val(res.data.user.trueName);
                $("#remark").val(res.data.user.remark);

                //开启编辑表单所在的弹层。注意编辑和新建的表单是一套模板
                layerid=layer.open({
                    area:'30%',
                    type: 1,
                    title:'编辑用户',
                    content: $('#editFormDiv') //这里content是一个DOM，注意：最好该元素要存放在body最外层，否则可能被其它的相对元素所影响
                });
            } else {
                layer.alert(res.msg);
                return false;
            }
        }
    });
};

function doDel(data) {
    layer.open({
        content: '确定要删除'+data.userName+'吗?',
        btn: ['yes', 'no'],//定义两个按钮，是和否
        yes: function(index, layero){//点击是时候的回调
            //do something
            layer.close(index); //如果设定了yes回调，需进行手工关闭

            //请求后台，执行删除操作
            $.ajax({
                type: "POST",
                url:"admin/user/delete",
                data:{id:data.id},
                async: false,
                error: function(request) {
                    layer.alert("与服务器连接失败/(ㄒoㄒ)/~~");
                },
                success: function(res) {
                    if(res.code == 0){
                        //打开成功消息提示
                        layer.alert("删除成功", {icon: 6}, function (index) {
                            //关闭当前frame
                            layer.close(index);
                            layer.close(layerid);//消息提示结束后回调，关闭上一级新建表单所在弹层
                            window.location.reload()
                        })
                    } else {
                        layer.alert(res.msg);
                    }
                }
            });
        }
    });
};

function setPermission(data) {
    //获得当前用户已经拥有的角色集合和未拥有的角色集合，并组装表单的复选按钮
    $.ajax({
        type: "POST",
        url:"admin/user/info",
        data:{id:data.id},
        async: false,
        error: function(request) {
            layer.alert("与服务器连接失败/(ㄒoㄒ)/~~");
        },
        success: function(res) {
            if(res.code == 0){
                $("#editRoleLabelId").html(data.id);//临时存放id，当提交时再去除赋值给input
                var roleList = res.data.roleList;//该记录已经拥有的记录集合
                var notInRolelist = res.data.notInRolelist;//该记录尚未拥有的记录集合
                var strs="";
                $.each(roleList, function (n, value) {//n从0开始自增+1；value为每次循环的单个对象
                    strs+='<input type="checkbox" name="role" title="'+value.name+'" value="'+value.id+'"  checked="checked">';
                });
                $.each(notInRolelist, function (n, value) {
                    strs+='<input type="checkbox" name="role" title="'+value.name+'"  value="'+value.id+'" >';
                });
                $("#checkboxlistid").empty();//每次填充前都要清空所有按钮，重新填充
                $("#checkboxlistid").append(strs);

                layui.form.render(); //更新全部

                layerid=layer.open({
                   /* skin: 'layui-layer-molv',*/
                    area:'60%',
                    type: 1,
                    title:'编辑用户角色',
                    content: $('#editRoleFormDiv') //这里content是一个DOM，注意：最好该元素要存放在body最外层，否则可能被其它的相对元素所影响
                });
            } else {
                layer.alert(res.msg);
                return false;
            }
        }
    });
}

</script>

</@Body>