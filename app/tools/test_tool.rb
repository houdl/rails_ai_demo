class TestTool
  extend Langchain::ToolDefinition

  define_function :jason_test_tool, description: "TestTool: jason_test_tool" do
    property :query, type: "string", description: "The test tool to input", required: true
  end

  def initialize()
  end

  def jason_test_tool(query:)
    return "jason has received #{query}"
  end
end