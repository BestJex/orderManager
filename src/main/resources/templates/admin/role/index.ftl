<#include "../../layout/layout.ftl"/>
<@Head title="角色管理">
<link rel="stylesheet" href="${basePath!}/static/css/ztree/bootstrapStyle/bootstrapStyle.css" type="text/css">
<script type="text/javascript" src="${basePath!}/static/js/ztree/jquery.ztree.core.js"></script>
<script type="text/javascript" src="${basePath!}/static/js/ztree/jquery.ztree.excheck.js"></script>
<script type="text/javascript" src="${basePath!}/static/js/ztree/jquery.ztree.exedit.js"></script>
</@Head>
<@Body>
<blockquote class="layui-elem-quote">
    <button class="layui-btn"  onclick="admin_show('新建角色','${basePath}/admin/role/create',400,400)"><i class="layui-icon"></i>添加</button>
</blockquote>
<table class="layui-table" id="layui_table_id" lay-filter="dataTable">

<script type="text/html" id="bar">
    <a class="layui-btn layui-btn-xs" lay-event="edit">编辑</a>
    <a class="layui-btn layui-btn-danger layui-btn-xs" lay-event="del">删除</a>
    <a class="layui-btn layui-btn-warm layui-btn-xs" lay-event="setPermission">菜单设置</a>
</script>

<#--带有 class="layui-fluid" 的容器中，那么宽度将不会固定，而是 100% 适应-->
<div id="editformdivid" hidden="" class="layui-fluid" style="margin: 15px;">
    <form class="layui-form" action="" id="editformid">
        <label hidden="true" id="editlabelid"></label>
        <input id="editid" name="id" value="" hidden/>
        <div class="layui-form-item">
            <label class="layui-form-label">角色名称</label>
            <div class="layui-input-block">
                <input type="text" id="name" name="name" lay-verify="name" autocomplete="off" placeholder="请输入角色名称" class="layui-input">
            </div>
        </div>
        <div class="layui-form-item">
            <label class="layui-form-label">备注</label>
            <div class="layui-input-block">
                <input type="text" id="remark" name="remark" autocomplete="off" placeholder="请输入备注信息" class="layui-input">
            </div>
        </div>
        <div class="layui-form-item">
            <div class="layui-input-block">
                <button class="layui-btn" lay-submit="" lay-filter="editSubmit">立即提交</button>
                <button id="reset" type="reset" class="layui-btn layui-btn-primary">重置</button>
            </div>
        </div>

    </form>
</div>

<#--菜单权限设置弹窗-->
<div  id="setpermisdiv" hidden="" class="layui-fluid" >
    <ul id="ztree" class="ztree"></ul>
    <button class="layui-btn layui-btn-sm" id="savesetpermis">保存权限设置</button>
    <button class="layui-btn layui-btn-sm" id="closesetpermis">关闭</button>
</div>


<script>
    var zTreeObj;
    var roleid;
    var layerid;//当前弹层id;这个id可以定义多个，主要的目的是为了在回调函数关闭弹层时使用的
    layui.use(['layer','form','layedit','laydate','table'], function(){
        var layer = layui.layer;
        var layedit = layui.layedit;
        var laydate = layui.laydate;
        var form = layui.form;

        var table = layui.table;
        table.render({
            id: "dataTable",//
            elem: '#layui_table_id',//指定表格元素
            url: 'admin/role/list',  //请求路径
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
                    field: 'name', //json对应的key
                    width: 200,
                    title: '角色名称',   //列名
                    align: 'center',
                    sort: false   // 默认为 false,true为开启排序
                },
                {
                    field: 'remark',
                    title: '备注',
                    align: 'center'
                },
                {fixed: 'right',  align: 'center',title:'操作', toolbar: '#bar', width:200}
            ]],
            parseData: function(res){
                data = res.data;
                return {
                    "code": res.code,
                    "count": data.count, //解析数据长度
                    "data": data.items //解析数据列表
                };
            }
        });
        table.on('tool(dataTable)', function(obj){
            var data = obj.data;
            if(obj.event === 'edit'){
               doEdit(data)
            } else if(obj.event === 'del'){
               doDel(data)
            } else if(obj.event === 'setPermission'){
                setPermission(data)
            }
        });

        //创建一个编辑器
        var editIndex = layedit.build('LAY_demo_editor');
        //自定义验证规则
        form.verify({
            name: function(value) {
                if(value.length < 3) {
                    return '角色名至少得3个字符';
                }
            },
            password: [/(.+){6,12}$/, '密码必须6到12位'],
            content: function(value) {
                layedit.sync(editIndex);
            }
        });


        //监听提交
        form.on('submit(editSubmit)', function(data) {
            //为了防止form中的id值被重置后置空,将编辑的id存放在label中
            $("#editid").val($("#editlabelid").html() );
            $("#editid").html("");

            $.ajax({
                type: "POST",
                url:"admin/role/edit",
                data:$('#editformid').serialize(),// 你的formid
                async: false,
                error: function(request) {
                    layer.alert("与服务器连接失败/(ㄒoㄒ)/~~");
                },
                success: function(res) {
                    if(res.code == 0){
                        layer.alert("操作成功", {icon: 6}, function (index) {
                            //关闭当前frame
                            layer.close(index);
                            layer.close(layerid);
                            $("#reset").click();//重置表单
                            window.location.reload()
                        })
                    } else {
                        layer.alert(res.msg);
                    }
                }
            });
            return false;//防止跳转
        });

        $('#savesetpermis').on('click', function () {

            var nodes = zTreeObj.getCheckedNodes(true);
            var menuArrIds=[];
            for(var i=0;i<nodes.length;i++){
                //alert(menuIds);
                menuArrIds.push(nodes[i].id);
            }
            var menuIds=menuArrIds.join(",");
            //alert(menuIds);

            $.ajax({
                type: "POST",
                url:"admin/role/saveMenuSet",
                data:{menuIds:menuIds,roleId:roleid},
                async: false,
                error: function(request) {
                    layer.alert("与服务器连接失败/(ㄒoㄒ)/~~");
                },
                success: function(res) {

                    if(res.code == 0){
                        layer.alert("操作成功", {icon: 6}, function (index) {
                            //关闭当前frame
                            layer.close(index);
                            layer.close(layerid);
                            //parent.location.reload();
                            location.reload();
                        })
                    } else {
                        layer.alert(res.msg);
                    }
                }
            });
        });


        $('#closesetpermis').on('click', function () {
            layer.close(layerid);
        });
    });

    function doEdit(data) {
        //请求后台，获取该记录的详细记录，并填充进表单
        $.ajax({
            type: "POST",
            url:"admin/role/info",
            async: false,
            data:{id:data.id},
            error: function(request) {
                layer.alert("与服务器连接失败/(ㄒoㄒ)/~~");
            },
            success: function(res) {
                if(res.code == 0){
                    $("#editlabelid").html(data.id);//临时存放id，当提交时再去除赋值给input
                    $("#name").val(res.data.name);
                    $("#remark").val(res.data.remark);

                    //开启编辑表单所在的弹层。注意编辑和新建的表单是一套模板
                    layerid=layer.open({
                       /* skin: 'layui-layer-molv',*/
                        area:'30%',
                        type: 1,
                        title:'编辑角色',
                        content: $('#editformdivid') //这里content是一个DOM，注意：最好该元素要存放在body最外层，否则可能被其它的相对元素所影响
                    });
                } else {
                    layer.alert(res.msg);
                    return false;
                }
            }
        });
    }
    function doDel(data) {
        layer.open({
            content: '请确定是否真的要删除角色为'+data.name+'的记录?',
            btn: ['yes', 'no'],//定义两个按钮，是和否
            yes: function(index, layero){//点击是时候的回调
                //do something
                layer.close(index); //如果设定了yes回调，需进行手工关闭

                //请求后台，执行删除操作
                $.ajax({
                    type: "POST",
                    url:"admin/role/delete",
                    data:{id:data.id},
                    async: false,
                    error: function(request) {
                        layer.alert("与服务器连接失败/(ㄒoㄒ)/~~");
                    },
                    success: function(res) {
                        if(res.code == 0){
                            //打开成功消息提示
                            layer.alert("操作成功", {icon: 6}, function (index) {
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
    }
    function setPermission(data) {
        roleid = data.id
        // zTree 的参数配置，深入使用请参考 API 文档（setting 配置详解）
        var setting = {
            check:{
                enable: true,
                chkStyle: "checkbox",
                chkboxType :{ "Y" : "p", "N" : "s" },
                nocheckInherit: true,
                chkDisabledInherit: true
            }
        };
        // zTree 的数据属性，深入使用请参考 API 文档（zTreeNode 节点数据详解）

        var zNodes = [
            {name:"test1", open:true, children:[
                    {name:"test1_1"}, {name:"test1_2"}]},
            {name:"test2", open:true, children:[
                    {name:"test2_1"}, {name:"test2_2"}]}
        ];

        $.ajax({
            type: "POST",
            url:'admin/role/loadCheckMenuInfo?parentId=1&roleId='+roleid,
            async: false,
            dataType: 'json',
            timeout: 1000,
            cache: false,
            error: function(request) {
                layer.alert("与服务器连接失败/(ㄒoㄒ)/~~");
            },
            success: function(data) {
                zNodes=data;
                zTreeObj = $.fn.zTree.init($("#ztree"), setting, zNodes);

                layerid=layer.open({//开启表单弹层
                   /* skin: 'layui-layer-molv',*/
                    type: 1,
                    area: ['460px', '500px'],
                    title:'设置权限',
                    content: $('#setpermisdiv') //这里content是一个DOM，注意：最好该元素要存放在body最外层，否则可能被其它的相对元素所影响
                });

            }
        });
    }

</script>

</@Body>