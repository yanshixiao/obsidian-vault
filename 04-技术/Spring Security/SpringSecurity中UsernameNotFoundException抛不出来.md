---
author: yuanshuai
created: 2022-03-18 18:49:44
aliases: 
description:
tags: [04-技术 java/spring-security]
---

[[UsernameNotFoundException]]抛不出来，主要因为DaoAuthenticationProvider默认hideUserNotFoundException的值是true

```java
@Bean  
public PasswordEncoder passwordEncoder() {  
    return new PasswordEncoder() {  
  
        @Override  
 public String encode(CharSequence rawPassword) {  
            return (String) rawPassword;  
 }  
        @Override  
 public boolean matches(CharSequence rawPassword, String encodedPassword) {  
            //return encodedPassword.equals(MD5Util.encode((String)rawPassword));  
 //实际使用的时候需要替换为这个，禁止密码明文在网路中传输  
 boolean equals = encodedPassword.equals((String) rawPassword);  
 if (!equals) {  
                throw new BadCredentialsException("您的密码有误，请检查后再试");  
 }  
            return equals;  
 }  
    };  
}  
  
  
@Bean  
public DaoAuthenticationProvider authenticationProvider() {  
    DaoAuthenticationProvider provider = new DaoAuthenticationProvider();  
 provider.setHideUserNotFoundExceptions(false);  
 provider.setUserDetailsService(userService);  
 provider.setPasswordEncoder(passwordEncoder());  
 return provider;  
}
```

