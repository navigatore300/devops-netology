# Домашнее задание к занятию "7.6. Написание собственных провайдеров для Terraform."

Бывает, что 
* общедоступная документация по терраформ ресурсам не всегда достоверна,
* в документации не хватает каких-нибудь правил валидации или неточно описаны параметры,
* понадобиться использовать провайдер без официальной документации,
* может возникнуть необходимость написать свой провайдер для системы используемой в ваших проектах.   

## Задача 1. 
Давайте потренируемся читать исходный код AWS провайдера, который можно склонировать от сюда: 
[https://github.com/hashicorp/terraform-provider-aws.git](https://github.com/hashicorp/terraform-provider-aws.git).
Просто найдите нужные ресурсы в исходном коде и ответы на вопросы станут понятны.  


1. Найдите, где перечислены все доступные `resource` и `data_source`, приложите ссылку на эти строки в коде на 
гитхабе.   

>resource  
https://github.com/hashicorp/terraform-provider-aws/blob/29a44d1f45cad3a890553c5fa2145bae0de46210/internal/provider/provider.go#L417  
data_source  
https://github.com/hashicorp/terraform-provider-aws/blob/8e4d8a3f3f781b83f96217c2275f541c893fec5a/aws/provider.go#L169  

2. Для создания очереди сообщений SQS используется ресурс `aws_sqs_queue` у которого есть параметр `name`.

* С каким другим параметром конфликтует `name`? Приложите строчку кода, в которой это указано.
> ConflictsWith: []string{"name_prefix"}  
https://github.com/hashicorp/terraform-provider-aws/blob/ad0cf62929dd5700d00db0222c5da14212d17266/internal/service/sqs/queue.go#L87  
* Какая максимальная длина имени?   
> Максимальная длинна имени - 80 символов.
Если fifoQueue то - 75 символов+.fifo  
https://github.com/hashicorp/terraform-provider-aws/blob/ad0cf62929dd5700d00db0222c5da14212d17266/internal/service/sqs/queue.go#L424  

 * Какому регулярному выражению должно подчиняться имя?   
> Если очередь fifo  
re = regexp.MustCompgile(`^[a-zA-Z0-9_-]{1,75}\.fifo$`) - символы английского алфавита обоих регистров, цифры, нижнее подчеркивание, дефис. Длинна имени до 75 символов и заканичвается на ".fifo".  
для остальных имен  
re = regexp.MustCompile(`^[a-zA-Z0-9_-]{1,80}$`) - символы английского алфавита обоих регистров, цифры, нижнее подчеркивание, дефис. Длинна имени до 80 символов.  
https://github.com/hashicorp/terraform-provider-aws/blob/ad0cf62929dd5700d00db0222c5da14212d17266/internal/service/sqs/queue.go#L424

    
## Задача 2. (Не обязательно) 
В рамках вебинара и презентации мы разобрали как создать свой собственный провайдер на примере кофемашины. 
Также вот официальная документация о создании провайдера: 
[https://learn.hashicorp.com/collections/terraform/providers](https://learn.hashicorp.com/collections/terraform/providers).

1. Проделайте все шаги создания провайдера.
2. В виде результата приложение ссылку на исходный код.
3. Попробуйте скомпилировать провайдер, если получится то приложите снимок экрана с командой и результатом компиляции.   
