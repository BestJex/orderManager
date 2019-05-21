package com.manager.controller;

import com.github.pagehelper.PageHelper;
import com.manager.entity.Orders;
import com.manager.entity.User;
import com.manager.model.PageRusult;
import com.manager.service.OrdersService;
import com.manager.service.dto.order.OrderListRequest;
import com.manager.service.dto.order.OrderListResponse;
import com.manager.util.ResponseMessage;
import org.apache.commons.lang3.StringUtils;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.shiro.authz.annotation.RequiresPermissions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;
import tk.mybatis.mapper.entity.Example;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.beans.IntrospectionException;
import java.io.*;
import java.lang.reflect.InvocationTargetException;
import java.text.ParseException;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/admin/order")
public class OrdersController {

    private final OrdersService ordersService;

    @Autowired
    public OrdersController(OrdersService ordersService) {
        this.ordersService = ordersService;
    }

    @RequestMapping(value = "/index", method = RequestMethod.GET)
    @RequiresPermissions(value = {"订单管理"})
    public ModelAndView index() {
        ModelAndView mv = new ModelAndView();
        mv.setViewName( "admin/order/index");
        return mv;
    }

    /**
     * 分页查询用户信息
     */
    @ResponseBody
    @RequestMapping(value = "/list")
    @RequiresPermissions(value = {"订单管理"})
    public ResponseMessage list(OrderListRequest request) throws Exception {

        Example orderExample = new Example(Orders.class);
        Example.Criteria criteria = orderExample.or();

        PageHelper.startPage(request.getPage(), request.getLimit());
        List<Orders> orderList = ordersService.selectByExample(orderExample);
        PageRusult<Orders> pageRusult =new PageRusult<Orders>(orderList);

        OrderListResponse data = new OrderListResponse();
        data.setCount((int)pageRusult.getTotal());
        data.setItems(orderList);

        return ResponseMessage.initializeSuccessMessage(data);
    }


    @RequestMapping(value = "/import", method = RequestMethod.POST)
    @RequiresPermissions(value = {"订单管理"})
    @ResponseBody
    public ResponseMessage orderUpload(MultipartFile file, HttpServletRequest request) throws Exception {
        try {
            //获取上传的文件
            if (file.isEmpty()) {
                try {
                    throw new Exception("文件不存在！");
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            InputStream in = null;
            try {
                in = file.getInputStream();
            } catch (IOException e) {
                return new ResponseMessage(ResponseMessage.SYSTEM_ERROR, "上传失败，系统异常");
            }

            //数据导入
            ordersService.importOrderExcel(in, file, request);
            in.close();
            return ResponseMessage.initializeSuccessMessage(null);
        }catch (Exception ex){
            ex.printStackTrace();
            throw ex;
        }
    }

    @RequestMapping("/export")
    @RequiresPermissions(value = {"订单管理"})
    @ResponseBody
    public void export(HttpServletRequest request, HttpServletResponse response) throws UnsupportedEncodingException, ClassNotFoundException, IntrospectionException, IllegalAccessException, ParseException, InvocationTargetException {

        String exportNo = null;
        Object object = request.getSession().getAttribute("currentUser");
        if(object instanceof User) {
            User user = (User) object;
            exportNo = String.format("%s_%s",user.getUserName(),System.currentTimeMillis());
        }

        response.reset(); //清除buffer缓存
        Map<String,Object> map = new HashMap<String,Object>();
        // 指定下载的文件名，浏览器都会使用本地编码，即GBK，浏览器收到这个文件名后，用ISO-8859-1来解码，然后用GBK来显示
        // 所以我们用GBK解码，ISO-8859-1来编码，在浏览器那边会反过来执行。
        response.setHeader("Content-Disposition", "attachment;filename=" + new String(String.format("%s.xlsx",exportNo).getBytes("GBK"),"ISO-8859-1"));
        response.setContentType("application/vnd.ms-excel;charset=UTF-8");
        response.setHeader("Pragma", "no-cache");
        response.setHeader("Cache-Control", "no-cache");
        response.setDateHeader("Expires", 0);
        XSSFWorkbook workbook = null;
        //导出Excel对象
        workbook = ordersService.exportOrderExcel(exportNo);
        OutputStream output;
        try {
            output = response.getOutputStream();
            BufferedOutputStream bufferedOutPut = new BufferedOutputStream(output);
            bufferedOutPut.flush();
            workbook.write(bufferedOutPut);
            bufferedOutPut.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
