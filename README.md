# NotesApp

Простое приложение для создания и редактирования заметок.

Key features:
- Возможность закрепить заметку вверху списка
- Задание цвета заметки
- Поиск по названию и содержимому заметки
- Возможность синхронизации заметок с Яндекс.Диск. Токен авторизации хранится в system keychain.


Главный экран приложения:

![Simulator Screen Shot - iPhone 12 - 2022-04-11 at 23 14 27](https://user-images.githubusercontent.com/3172532/162824906-96cfd89c-26b1-42a9-9c43-7c638fc0b5ce.png)

Поиск заметок:

![Simulator Screen Shot - iPhone 12 - 2022-04-11 at 23 24 53](https://user-images.githubusercontent.com/3172532/162825926-4e2fd73b-91b4-46bf-9016-515b41600552.png)


Экран редактирования заметки:

![Simulator Screen Shot - iPhone 12 - 2022-04-11 at 22 49 23](https://user-images.githubusercontent.com/3172532/162826104-9df676b3-a0ec-40a2-a21f-2460573ad3a8.png)


Выбор цвета заметки:

![Simulator Screen Shot - iPhone 12 - 2022-04-11 at 22 49 57](https://user-images.githubusercontent.com/3172532/162826443-6a2dcc6f-e1d7-4783-b945-849436eead4f.png)

Экран синхронизации:

![Simulator Screen Shot - iPhone 12 - 2022-04-11 at 23 44 59](https://user-images.githubusercontent.com/3172532/162829056-87b4440c-79c2-4801-b2a0-d3a434b1617c.png)


![Simulator Screen Shot - iPhone 12 - 2022-04-11 at 23 34 54](https://user-images.githubusercontent.com/3172532/162827458-9459f949-f494-4559-a001-37d05d4711bb.png)


## Сборка проекта
Для корректной работы приложения нужно зарегистировать приложение на https://oauth.yandex.ru/

Для приложения указать любой callback URL со схемой awesomenotes. Например, awesomenotes://token

После регистрации приложения прописать полученный client id в поле с ключом CLIENT_ID в файл YandexDiskApp-Info.plist, который будет сгенирирован при первой сборке приложения.
