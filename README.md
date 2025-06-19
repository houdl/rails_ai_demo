# AI 聊天系统

基于 Rails 7.2 + LangChain + OpenAI 构建的智能聊天系统。

## 功能特性

- 🤖 集成 OpenAI GPT 模型进行智能对话
- 💬 支持多个聊天会话管理
- 🎨 使用 Bootstrap 5 构建现代化界面
- ⚡ 使用 Stimulus 实现交互功能
- 📱 响应式设计，支持移动端
- 🔄 实时消息滚动
- ⌨️ 支持 Ctrl+Enter 快速发送消息

## 技术栈

- **后端**: Ruby 3.4.2 + Rails 7.2
- **数据库**: PostgreSQL
- **前端**: Bootstrap 5 + Stimulus
- **JavaScript 管理**: Importmap
- **AI 集成**: LangChain + OpenAI API

## 安装和运行

### 1. 克隆项目
```bash
git clone <repository-url>
cd rails_ai_demo
```

### 2. 安装依赖
```bash
# 确保使用 Ruby 3.4.2
rvm use 3.4.2

# 安装 gems
bundle install
```

### 3. 配置数据库
```bash
# 创建数据库
rails db:create

# 运行迁移
rails db:migrate
```

### 4. 配置环境变量
```bash
# 复制环境变量模板
cp .env.example .env

### 5. 启动服务器
```bash
rails server
```

访问 http://localhost:3000 开始使用聊天系统。

## 使用说明

### 执行 Roast 工作流
```bash
# 设置环境变量
export OPENROUTER_API_KEY=your-openrouter-api-key

# 执行工作流
roast execute my_cool_workflow /Users/jason/rails/rails_ai_demo/tmp/test.md
```

![image](https://github.com/user-attachments/assets/42b34917-08b1-44fb-bc40-d731e78952f5)
![image](https://github.com/user-attachments/assets/216e0422-ab5c-4850-b829-70cb5b3ab6a2)
![image](https://github.com/user-attachments/assets/fcdded29-5325-47b0-a1a7-bea39c0f095b)


### 创建新聊天
1. 点击"新建聊天"按钮
2. 输入聊天标题
3. 点击"创建聊天"

### 发送消息
1. 在消息输入框中输入内容
2. 点击"发送"按钮或按 Ctrl+Enter
3. AI 将自动回复您的消息

### 管理聊天
- 在聊天列表中查看所有对话
- 点击聊天标题进入对话
- 使用"删除"按钮删除不需要的聊天

## 项目结构

```
app/
├── controllers/
│   ├── chats_controller.rb      # 聊天管理控制器
│   └── messages_controller.rb   # 消息处理控制器
├── models/
│   ├── chat.rb                  # 聊天模型
│   └── message.rb               # 消息模型
├── views/
│   ├── chats/
│   │   ├── index.html.erb       # 聊天列表页面
│   │   ├── new.html.erb         # 新建聊天页面
│   │   └── show.html.erb        # 聊天详情页面
│   └── layouts/
│       └── application.html.erb # 应用布局
└── javascript/
    ├── application.js           # JavaScript 入口文件
    └── controllers/             # Stimulus 控制器
        ├── form_validation_controller.js
        ├── message_form_controller.js
        └── chat_scroll_controller.js

roast/
└── my_cool_workflow/
    ├── workflow.yml
    ├── analyze_input/
    │   └── prompt.md
    └── generate_response/
        └── prompt.md
```


## 自定义配置

### 修改 AI 模型
在 `app/controllers/messages_controller.rb` 中的 `generate_ai_response` 方法中，您可以：
- 修改 AI 提示词
- 调整模型参数
- 添加更多的对话上下文

### 样式定制
- 修改 `app/assets/stylesheets/application.css` 来自定义样式
- 使用 Bootstrap 类来快速调整界面

### 添加新功能
- 在 `app/javascript/controllers/` 中添加新的 Stimulus 控制器
- 扩展模型以支持更多字段
- 添加用户认证系统

## 故障排除

### JavaScript 加载问题
如果遇到 JavaScript 文件加载错误，请检查：
1. `config/importmap.rb` 配置是否正确
2. Stimulus 控制器文件路径是否正确
3. 运行 `rails assets:precompile` 重新编译资源

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目！

## 许可证

MIT License
