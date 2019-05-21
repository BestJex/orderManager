<#include "../../layout/layout.ftl"/>
<@Head title="角色管理">
<link rel="stylesheet" href="${basePath!}/static/css/ztree/bootstrapStyle/bootstrapStyle.css" type="text/css">
<script type="text/javascript" src="${basePath!}/static/js/ztree/jquery.ztree.core.js"></script>
<script type="text/javascript" src="${basePath!}/static/js/ztree/jquery.ztree.excheck.js"></script>
<script type="text/javascript" src="${basePath!}/static/js/ztree/jquery.ztree.exedit.js"></script>
</@Head>
<@Body>
<blockquote class="layui-elem-quote">
    <button type="button" class="layui-btn" id="importOrder">
        <i class="layui-icon">&#xe62f;</i>导入订单
    </button>
<button type="button" class="layui-btn" id="exportOrder">
        <i class="layui-icon">&#xe601;</i>导出订单
    </button>
</blockquote>
<table class="layui-table" id="layui_table_id" lay-filter="dataTable">


<script>
    var zTreeObj;
    var roleid;
    var layerid;//当前弹层id;这个id可以定义多个，主要的目的是为了在回调函数关闭弹层时使用的
    layui.use(['element','upload','table'], function() {
        var element = layui.element;
        var upload = layui.upload;

        var table = layui.table;
        table.render({
            id: "dataTable",//
            elem: '#layui_table_id',//指定表格元素
            url: 'admin/order/list',  //请求路径
            cellMinWidth: 20,//全局定义常规单元格的最小宽度，layui 2.2.1 新增
            even: true,   //隔行换色
            page: true, //开启分页
            limits: [20, 50, 100],  //每页条数的选择项，默认：[10,20,30,40,50,60,70,80,90]。
            limit: 20,//每页默认显示的数量
            method: 'get',  //提交方式
            cols: [[
                {
                    field: 'id',
                    hide: true
                },
                {
                    field: 'importNo', //json对应的key
                    width: 200,
                    title: '导入编号',   //列名
                    align: 'center',
                    sort: false   // 默认为 false,true为开启排序
                },
                {
                    field: 'taskNo',
                    title: '任务编号',
                    align: 'center'
                },
                {
                    field: 'orderNo',
                    title: '订单编号',
                    align: 'center'
                },
                {
                    field: 'shop',
                    title: '店铺名',
                    align: 'center'
                },
                {
                    field: 'taobao',
                    title: '淘宝账号',
                    align: 'center'
                },
                {
                    field: 'enPrice',
                    title: '录入价格',
                    align: 'center',
                    templet: "<div>{{ d.enPrice/100 }}</div>"
                },
                {
                    field: 'realPrice',
                    title: '实际价格',
                    align: 'center',
                    templet: "<div>{{ d.realPrice/100 }}</div>"
                },
                {
                    field: 'status',
                    title: '订单状态：1、代拍下，2、已拍下，3、已付款，4、其他',
                    align: 'center'
                },
                {
                    field: 'signStatus',
                    title: '标旗状态：1、等待标记，2、标记成功，3、标记失败，4、未订购应用',
                    align: 'center'
                },
                {
                    field: 'endTime',
                    title: '截止时间',
                    align: 'center',
                    templet: "<div>{{layui.util.toDateString(d.endTime, 'yyyy-MM-dd')}}</div>"
                }
            ]],
            parseData: function (res) {
                data = res.data;
                return {
                    "code": res.code,
                    "count": data.count, //解析数据长度
                    "data": data.items //解析数据列表
                };
            },
            done: function () {
                $("[data-field='enPrice']").children().each(function () {
                    $(this).text = $(this).text * 100
                });
                $("[data-field='realPrice']").children().each(function () {
                    $(this).text = $(this).text * 100
                });
                $("[data-field='status']").children().each(function () {
                    if ($(this).text() == '1') {
                        $(this).text("代拍下")
                    } else if ($(this).text() == '2') {
                        $(this).text("已拍下")
                    } else if ($(this).text() == '3') {
                        $(this).text("已付款")
                    } else if ($(this).text() == '4') {
                        $(this).text("其他")
                    }
                });
                $("[data-field='signStatus']").children().each(function () {
                    if ($(this).text() == '1') {
                        $(this).text("等待标记")
                    } else if ($(this).text() == '2') {
                        $(this).text("标记成功")
                    } else if ($(this).text() == '3') {
                        $(this).text("标记失败")
                    } else if ($(this).text() == '4') {
                        $(this).text("未订购应用")
                    }
                });
            }
        });

        upload.render({
            elem: '#importOrder',
            url: 'admin/order/import',
            accept: 'file', //普通文件
            done: function (res) {
                //上传完毕
                if (res.code == 0) {
                    layer.alert("导入成功", {icon: 6}, function (index) {
                        layer.close(index);
                        window.location.reload();
                    })
                } else {
                    layer.msg('导入失败');
                }

            }
        });

        $('#exportOrder').on('click', function () {

            window.open('admin/order/export')
            //如果window.open是在一个ajax回调里执行，浏览器会被安全拦截，解决方案：
           /* $.ajax({
                url: 'admin/order/export',
                success: function () {
                    window.open('admin/order/export')
                },
                error: function (data, XMLHttpRequest, textStatus,
                                 errorThrown) {
                    layer.msg('导出异常');

                }
            });
            return false;*/
        })
    })


</script>

</@Body>