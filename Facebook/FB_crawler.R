
rm(list=ls())
library(httr)
library(magrittr)
library(rlist)
access_token = ''
fb_id = ''
time = 10

#posts
url = sprintf('https://graph.facebook.com/v2.8/%s?fields=posts&access_token=%s',fb_id, access_token)
data_post = data.frame()

res = GET(url, timeout(time))
res = res %>% content()
#str(res)
url = res$posts$paging$`next`
data = list.filter(res$posts$data, is.character(message))
data = lapply(list.select(data, message,created_time,id), as.data.frame)
data = (do.call(rbind, data))
data_post = rbind(data_post,data)

########################
while (TRUE) {
  if(!is.null(url)){
    res = GET(url, timeout(time))
    res = res %>% content()
    url = res$paging$`next`
    print(url)
    data = list.filter(res$data, is.character(message))
    data = lapply(list.select(data, message,created_time,id), as.data.frame)
    data = (do.call(rbind, data))
    data_post = rbind(data_post,data)
  }
  else{
    break
  }
}

View(data_post)
########################


#comments
data_post_comments = data.frame()

for (i in 1:length(data_post$id)){
  id = as.character(data_post$id[i])
  url = sprintf('https://graph.facebook.com/v2.8/%s/comments?access_token=%s',id, access_token)
  #url = sprintf('https://graph.facebook.com/v2.8/%s?fields=comments&access_token=%s',id, access_token)
  
  res = GET(url, timeout(time))
  res = res %>% content()
  url = res$paging$`next`
  data = list.filter(res$data, is.character(message))
  data = lapply(list.select(data, from, message,created_time,id), as.data.frame)
  data = (do.call(rbind, data))
  data_post_comments = rbind(data_post_comments,data)
  
  while (TRUE) {
    if(!is.null(url)){
      res = GET(url, timeout(time))
      res = res %>% content()
      url = res$paging$`next`
      data = list.filter(res$data, is.character(message))
      data = lapply(list.select(data, from, message,created_time,id), as.data.frame)
      data = (do.call(rbind, data))
      data_post_comments = rbind(data_post_comments,data)
    }
    else{
      break
    }
  }
}

#check  
test = data.frame(do.call(rbind, strsplit(unique(as.character(data_post_comments$id)),"_")))
length(unique(test[,1]))

###reactions__ if no comments or likes
data_post_reactions = data.frame()

for (i in 1:length(data_post$id)){
  id = as.character(data_post$id[i])
  url = sprintf('https://graph.facebook.com/v2.8/%s/reactions?&access_token=%s',id, access_token)
  
  res = GET(url, timeout(time))
  res = res %>% content()
  url = res$paging$`next`
  data = list.filter(res$data, is.character(id))
  data = lapply(list.select(data, name, type, id), as.data.frame)
  data = do.call(rbind, data)
  
  if(!is.null(data)){
    data = cbind(data, id)
    data_post_reactions = rbind(data_post_reactions,data)
    }
  
  while (TRUE) {
    if(!is.null(url)){
      res = GET(url, timeout(time))
      res = res %>% content()
      url = res$paging$`next`
      data = list.filter(res$data, is.character(id))
      data = lapply(list.select(data, name, type, id), as.data.frame)
      data = do.call(rbind, data)
      data = cbind(data, id)
      data_post_reactions = rbind(data_post_reactions,data)
    }
    else{
      break
    }
  }
}

write.csv(data_post,"FB_Post")
write.csv(data_post_comments,"FB_Comments")
write.csv(data_post_reactions,"FB_CommentReactions")
