package main

import (
	"database/sql"
	_ "github.com/rainingmaster/mysql"
	"testing"
)

func TestFixNoPass(t *testing.T) {
	db, err := sql.Open("mysql", "nopass_old:@(127.0.0.1)/golang_test?allowOldPasswords=true")
	if err != nil {
		t.Fatalf("connect failed: %v", err.Error())
	}

	_, err = db.Query("select * from cats order by id desc;")
	if err != nil {
		t.Fatalf("select failed: %v", err.Error())
	}
}

func TestFixWithPass(t *testing.T) {
	db, err := sql.Open("mysql", "user_old:pass_old@(127.0.0.1)/golang_test?allowOldPasswords=true")
	if err != nil {
		t.Fatalf("connect failed: %v", err.Error())
	}

	_, err = db.Query("select * from cats order by id desc;")
	if err != nil {
		t.Fatalf("select failed: %v", err.Error())
	}
}
