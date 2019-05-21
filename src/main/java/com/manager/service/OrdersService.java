package com.manager.service;

import com.manager.entity.Orders;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import java.beans.IntrospectionException;
import java.io.InputStream;
import java.lang.reflect.InvocationTargetException;
import java.text.ParseException;

public interface OrdersService extends IService<Orders> {

    void importOrderExcel(InputStream in, MultipartFile file, HttpServletRequest request) throws Exception;

    XSSFWorkbook exportOrderExcel(String exportNo) throws InvocationTargetException, ClassNotFoundException, IntrospectionException, ParseException, IllegalAccessException;
}
