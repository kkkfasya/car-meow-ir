target triple = "x86_64-pc-linux-gnu" ; NOTE: may need to change depending on your machine

@stderr = external global ptr, align 8 ; stderr somehow declared like this

@cat_file = private unnamed_addr constant [8 x i8] c"cat.jpg\00", align 1
@write_mode = private unnamed_addr constant [3 x i8] c"wb\00", align 1

@user_agent = private unnamed_addr constant [115 x i8] c"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.82 Safari/537.36\00", align 1
@cat_url = private unnamed_addr constant [23 x i8] c"https://cataas.com/cat\00", align 1

@err_msg = private unnamed_addr constant [61 x i8] c"[ERROR] PROBLEM OCCURED WHEN DOWNLOAD CAT :(\0AERROR CODE: %s\0A\00", align 1
@happy_cat_msg_yippyy = private unnamed_addr constant [34 x i8] c"[INFO] CAT SUCCESFULLY DOWNLOADED\00", align 1 ; TODO: add yippy emoji


define dso_local i32 @main() #0 {
  %stderr = load ptr, ptr @stderr, align 8

  ; CURLOPT ENUM
  %ptr_CURLOPT_URL = alloca i32, align 8 
  %ptr_CURLOPT_USERAGENT = alloca i32
  %ptr_CURLOPT_TIMEOUT = alloca i32
  %ptr_CURLOPT_WRITEDATA = alloca i32 
  %timeout = alloca i32
  %file = call ptr @fopen(ptr noundef @cat_file, ptr noundef @write_mode)

  ; the value of enum members are like this because of in CURLOPT macro in CURLoption enum
  store i32 10002, ptr %ptr_CURLOPT_URL
  store i32 10018, ptr %ptr_CURLOPT_USERAGENT
  store i32 13, ptr %ptr_CURLOPT_TIMEOUT
  store i32 10001, ptr %ptr_CURLOPT_WRITEDATA

  ; NOTE:    v -> change the timeout value here
  store i32 10, ptr %timeout 

  %CURLOPT_URL = load i32, ptr %ptr_CURLOPT_URL
  %CURLOPT_USERAGENT = load i32, ptr %ptr_CURLOPT_USERAGENT
  %CURLOPT_TIMEOUT = load i32, ptr %ptr_CURLOPT_TIMEOUT
  %CURLOPT_WRITEDATA = load i32, ptr %ptr_CURLOPT_WRITEDATA


  ;init & setopt
  %curl_handle = call ptr @curl_easy_init()
  call i32 (ptr, i32, ...) @curl_easy_setopt(ptr noundef %curl_handle, i32 noundef %CURLOPT_URL, ptr noundef @cat_url)
  call i32 (ptr, i32, ...) @curl_easy_setopt(ptr noundef %curl_handle, i32 noundef %CURLOPT_USERAGENT, ptr noundef @user_agent)
  call i32 (ptr, i32, ...) @curl_easy_setopt(ptr noundef %curl_handle, i32 noundef %CURLOPT_TIMEOUT, ptr noundef %timeout)
  call i32 (ptr, i32, ...) @curl_easy_setopt(ptr noundef %curl_handle, i32 noundef %CURLOPT_WRITEDATA, ptr noundef %file)

  ; perform
  %curl_code = call i32 @curl_easy_perform(ptr noundef %curl_handle)

  ; if error
  %curl_strerr = call ptr @curl_easy_strerror(i32 noundef %curl_code)
  %compare_res = icmp ne i32 %curl_code, 0 ; ne stands for not equal, and CURLE_OK is 0

  br i1 %compare_res, label %error, label %succes ; basically goto

error:
  call i32 @fclose(ptr noundef %file)
  call void @curl_easy_cleanup(ptr noundef %curl_handle)
  call i32 (ptr, ptr, ...) @fprintf(ptr noundef %stderr, ptr noundef @err_msg,  ptr noundef %curl_strerr)

  ret i32 1

succes:
  call i32 @fclose(ptr noundef %file)
  call i32 @printf(ptr noundef @happy_cat_msg_yippyy)
  call void @curl_easy_cleanup(ptr noundef %curl_handle)

  ret i32 0
}

; curl
declare ptr @curl_easy_init() #1
declare i32 @curl_easy_setopt(ptr noundef, i32 noundef, ...) #1
declare i32 @curl_easy_perform(ptr noundef) #1
declare ptr @curl_easy_strerror(i32 noundef) #1
declare void @curl_easy_cleanup(ptr noundef) #1
; stdio
declare ptr @fopen(ptr noundef, ptr noundef) #1
declare i32 @fprintf(ptr noundef, ptr noundef, ...) #1
declare i32 @printf(ptr noundef, ...) #1
declare i32 @fclose(ptr noundef) #1
