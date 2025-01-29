---
banner: "https://api.dujin.org/bing/1920.php"
obsidianUIMode: preview
banner_y: 0.528
---

%%倒计时%%
> [!倒计时]
> #### 倒计时
>> 今年已过去 <%*+ tR+= moment().diff(tp.date.now("YYYY-1-1"), "days") %> 天
>> 
>> 距春节还有<%*+ let edate = moment("2024-02-10", "yyyy-MM-DD"); let from = moment().startOf('day'); edate.diff(from, "days") >= 0 ? tR += edate.diff(from, "days") : tR += edate.add(1, "year").diff(from, "days") %> 天

%%随机文件%%
> [!随机文件|blue]
>```dataviewjs
let reg=/[\u4e00-\u9fa5]/
let nofold = '!"88-Template" and !"99-Attachment" and !"50-Inbox" and !"20-Diary"'
let files = dv.pages(nofold).file
const random = Math.floor(Math.random() * (files.length - 1))
const randomNote = files[random]
dv.paragraph(randomNote.link)
const sampleTFile = this.app.vault.getAbstractFileByPath(randomNote.path);
const contents = await this.app.vault.cachedRead(sampleTFile); 
let lines = contents.split("---\n").filter(line => line.match(reg))
const randomline = Math.floor(Math.random() * (lines.length - 1))
lines = lines[randomline]?.replace(/(\r|\n|#|-|\*|\t|\>)/gi,"").substr(0,80) + '...';
dv.span(lines)
>```

![[从这开始]]
