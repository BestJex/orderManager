package com.manager.service.dto.user;

import com.manager.entity.User;

import java.util.List;

public class UserListResponse {
    private int count;
    private List<User> items;

    public int getCount() {
        return count;
    }

    public void setCount(int count) {
        this.count = count;
    }

    public List<User> getItems() {
        return items;
    }

    public void setItems(List<User> items) {
        this.items = items;
    }
}
