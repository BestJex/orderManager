package com.manager.util;

import com.fasterxml.jackson.annotation.JsonInclude;

public class ResponseMessage {
    public final static int SUCCESS = 0;
    public final static int SYSTEM_ERROR = 1;
    public final static int ILLEGAL_OPERATION = 2;
    public final static int TOKEN_ERROR = 3;
    public final static int NO_MAPPING_URL = 4;
    public final static int PARAMETER_ERROR = 10;

    private int code;
    private String msg;
    @JsonInclude(JsonInclude.Include.NON_NULL)
    private Object data;

    public static ResponseMessage  initializeSuccessMessage(Object data){
        ResponseMessage rm = new ResponseMessage(ResponseMessage.SUCCESS, "success", data);
        return rm;
    }

    public ResponseMessage(int code){
        this.code = code;
    }

    public ResponseMessage(int code, String msg){
        this.code = code;
        this.msg = msg;
    }

    public ResponseMessage(int code, String msg, Object data){
        this.code = code;
        this.msg = msg;
        this.data = data;
    }

    public ResponseMessage(int code, long count, String msg, Object data){
        this.code = code;
        this.msg = msg;
        this.data = data;
    }

    public void setMsg(String msg) { this.msg = msg; }

    public void setData(Object data) { this.data = data; }

    public int getCode() { return code; }

    public String getMsg() { return msg; }

    public Object getData() { return data; }
}
