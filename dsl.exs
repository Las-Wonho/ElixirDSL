defmodule Message do

  def send(block) do
  end

  def to(user) do
    Agent.update(MessageMember, fn x -> [user | x] end)
  end

  def msg(message) do
    Agent.update(MessageString, fn x -> message end)
  end

  def time(count, type) do
    users = Agent.get(MessageMember, fn x -> x end)
    message = Agent.get(MessageString, fn x -> x end)
    sender(fn -> Enum.each(users, fn user ->
        Agent.update(Messages, fn x -> Map.put(x, user, message) end)
      end)
    end, count)
  end

  def sender(f, timeout) do
    spawn_link(fn ->
      Process.sleep(timeout)
      f.()
    end)
  end

end

{:ok, pid} = Agent.start_link(fn -> %{} end, name: Messages)
{:ok, pid} = Agent.start_link(fn -> "" end, name: MessageString)
{:ok, pid} = Agent.start_link(fn -> [] end, name: MessageMember)


# TEST-1
Message.send do
  Message.msg("hello")
  Message.to("las")
  Message.to("dalgona")
  Message.time(100, "sec")
end

# ASSERT
IO.puts(Agent.get(Messages, fn x -> x["las"] end) == nil)
IO.puts(Agent.get(Messages, fn x -> x["dalgona"] end) == nil)
:timer.sleep(120)
IO.puts(Agent.get(Messages, fn x -> x["las"] end) == "hello")
IO.puts(Agent.get(Messages, fn x -> x["dalgona"] end) == "hello")

# TEST-2
Message.send do
  Message.msg("hi")
  Message.to("user1")
  Message.time(10, "min")
end

# ASSERT
IO.puts(Agent.get(Messages, fn x -> x["user1"] end) == nil)
:timer.sleep(120)
IO.puts(Agent.get(Messages, fn x -> x["user1"] end) == "hi")
