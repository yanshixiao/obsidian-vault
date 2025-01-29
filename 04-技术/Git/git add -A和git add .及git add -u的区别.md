git add -A  
git add .  
git add -u  
在功能上看似很相近，但还是存在一点差别

>git add . ：他会监控工作区的状态树，使用它会把工作时的所有变化提交到暂存区，包括文件内容修改(modified)以及新文件(new)以及删除的文件（2版本以后）。

>git add -u ：他仅监控已经被add的文件（即tracked file），他会将被修改的文件提交到暂存区。add -u 不会提交新文件（untracked file）。（git add --update的缩写）

>git add -A ：是上面两个功能的合集（git add --all的缩写）2版本等同于git add .

    git init
    echo Change me > change-me
    echo Delete me > delete-me
    git add change-me delete-me
    git commit -m initial
    
    echo OK > change-me
    rm delete-me
    echo Add me > add-me
    
    git status
    # Changed but not updated:
    #   modified:   change-me
    #   deleted:    delete-me
    # Untracked files:
    #   add-me
    
    git add .
    git status
    
    # Changes to be committed:
    #   new file:   add-me
    #   modified:   change-me
    #   deleted:    delete-me
    
    git reset
    
    git add -u
    git status
    
    # Changes to be committed:
    #   modified:   change-me
    #   deleted:    delete-me
    # Untracked files:
    #   add-me