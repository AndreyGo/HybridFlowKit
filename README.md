# 📘 **Техническое задание**

## **Создание архитектурного мини-фреймворка HybridFlowKit (Swift Package)**

### Для построения гибридных iOS-приложений (UIKit + SwiftUI + Flow)

---

# 1. Общая цель фреймворка

Создать автономный Swift Package (`HybridFlowKit`), который предоставляет архитектурную инфраструктуру для создания гибридных приложений iOS.

Фреймворк должен включать:

* единый механизм **Flow / Координаторов**,
* систему **навигации через протоколы Navigator**,
* универсальные **UIKit-контейнеры**, внутри которых встраивается SwiftUI,
* контейнер для “скрывающейся шапки” (**CollapsingHeaderViewController**),
* инфраструктуру для создания модулей экранов (**ScreenModule**),
* базовые типы и хелперы для удобной интеграции.

Фреймворк *не должен* содержать логики конкретного приложения. Только механизм навигации и UI-контейнеров.

Фреймворк должен быть **полностью независим**, легко подключаемый через Swift Package Manager в любое приложение.

---

# 2. Требования к структуре репозитория

Codex должен создать репозиторий в следующем виде:

```
HybridFlowKit/
├── Package.swift
└── Sources/
    └── HybridFlowKit/
        ├── Core/
        ├── Navigation/
        ├── Containers/
        ├── Integration/
        └── Utils/
```

Все исходники фреймворка находятся строго внутри:

```
Sources/HybridFlowKit/
```

---

# 3. Требования к содержимому модулей фреймворка

---

## 3.1. Core — базовые протоколы, ядро Flow

Папка:

```
Sources/HybridFlowKit/Core/
```

Обязательные файлы:

### **1. AppStateController.swift**

Содержит:

* enum `AppState`:

  * `.splash`
  * `.onboarding`
  * `.authorized`
  * `.guest`
  * `.banned`

* класс `AppStateController`

  * свойство `currentState: AppState`
  * метод `setState(_:)`
  * метод `makeFlow(for state:) -> Flow`
  * свойство `currentFlow: Flow?`
  * метод `currentRootViewController() -> UIViewController`
  * onFlowFinish обработчик

### **2. Flow.swift**

Протокол:

```
protocol Flow: AnyObject {
    var rootViewController: UIViewController { get }
    var onFinish: ((FlowFinishEvent) -> Void)? { get set }
    func start()
}
```

### **3. FlowFinishEvent.swift**

enum:

```
enum FlowFinishEvent {
    case completed
    case cancelled
    case logout
    case switchToAuthorized
    case switchToOnboarding
    case switchToGuest
    case switchToBanned
}
```

### **4. FlowCoordinator.swift**

Базовый класс:

* хранит `UINavigationController`
* реализует `Flow` базово
* предоставляет методы:

  * `push(_ module: ScreenModule, animated: Bool)`
  * `present(_ module: ScreenModule, animated: Bool)`
  * `pop(animated: Bool)`
  * `finish(_ event: FlowFinishEvent)`

---

# 3.2. Navigation — навигаторы и контекст навигации

Папка:

```
Sources/HybridFlowKit/Navigation/
```

Обязательные файлы:

### **1. Navigator.swift**

Базовый протокол без деталей:

```
protocol Navigator: AnyObject {}
```

Codex должен документировать назначение.

### **2. NavigationContext.swift**

Структура:

* хранит:

  * `navigationController: UINavigationController?`
  * `tabBarController: UITabBarController?`
  * `presentingViewController: UIViewController?`

### **3. NavigationControllerProvider.swift**

Хелпер:

* метод `makeNavigationController() -> UINavigationController`
* метод `root(_ viewController:)`

### **4. TabBarControllerProvider.swift**

Хелпер:

* метод `makeTabBarController() -> UITabBarController`

---

# 3.3. Containers — UI-контейнеры

Папка:

```
Sources/HybridFlowKit/Containers/
```

Обязательные файлы:

### **1. BaseHostingViewController.swift**

UIViewController, который:

* принимает SwiftUI View
* размещает UIHostingController внутри
* управляет:

  * добавлением child VC,
  * корректной иерархией,
  * статус-баром
  * логированием (если включено)

### **2. CollapsingHeaderViewController.swift**

Универсальный контейнер:

* headerView (UIView)
* scrollView / collectionView
* вычисление progress collapse:

  * свойство `headerCollapseProgress: CGFloat`
* делегат:

  * `CollapsingHeaderDelegate`

    * `didUpdateProgress(_:)`
    * `didReachEnd()`
* поддержка lazy load (доскроллили → сообщить наружу)

---

# 3.4. Integration — модули, фабрики экранов

Папка:

```
Sources/HybridFlowKit/Integration/
```

Обязательные файлы:

### **1. ScreenModule.swift**

Структура:

```
struct ScreenModule {
    let viewController: UIViewController
    let retainCycle: AnyObject?   // ViewModel если нужно
}
```

### **2. ScreenFactory.swift**

Протокол:

```
protocol ScreenFactory {
    associatedtype Route
    func make(route: Route) -> ScreenModule
}
```

---

# 3.5. Utils — утилиты

Папка:

```
Sources/HybridFlowKit/Utils/
```

Обязательные файлы:

### **1. Logger.swift**

* включаемый/выключаемый лог
* выводит переходы между Flow
* выводит push/pop/present

### **2. Extensions**

* `UIViewController+Child.swift`: удобные методы добавления child VC
* `UINavigationController+Convenience.swift`

---

# 4. Требования к Package.swift

Codex должен создать валидный пакет:

* минимальная версия:

  * iOS 15+
* поддержка Swift Concurrency
* библиотеки:

  * UIKit
  * SwiftUI

Примерная структура:

```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "HybridFlowKit",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "HybridFlowKit", targets: ["HybridFlowKit"])
    ],
    targets: [
        .target(
            name: "HybridFlowKit",
            dependencies: [],
            path: "Sources/HybridFlowKit",
            resources: []
        )
    ]
)
```

Codex должен вставить и корректно оформить.

---

# 5. Требования к коду

* Чистые протоколы, без привязки к конкретному проекту.
* UIKit и SwiftUI использовать совместно.
* Методы документировать комментарием.
* Фреймворк должен собираться без ошибок.
* Структура файлов строго соответствовать ТЗ.
* Код писать в стиле Apple (swiftlint-friendly).

---

# 6. Требования к документации внутри фреймворка

Codex должен добавить:

1. **README.md** с:

   * описанием назначения фреймворка,
   * схемой структуры директорий,
   * примером использования Flow,
   * примером создания Navigator в реальном приложении.

2. Док-комментарии к каждому протоколу.

---

# 7. Что НЕ нужно делать

* Не реализовывать реальные экраны (Home, Chat…).
* Не добавлять зависимости (Combine, Alamofire и т.п.).
* Не привязывать фреймворк к конкретному API.
* Не добавлять бизнес-логику.

---

# 8. Главная цель

Codex должен в точности создать:

* файловую структуру,
* каркас классов,
* протоколы,
* контейнеры,
* документацию,
* Package.swift,
* чистые пустые реализации,

чтобы после импорта этого пакета в приложение можно было начать строить потоки OnboardingFlow, AuthorizedFlow и любые другие.


