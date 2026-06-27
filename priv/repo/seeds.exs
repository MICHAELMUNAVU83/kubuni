# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Kubuni.Repo.insert!(%Kubuni.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Kubuni.Catalog.{Course, CourseModule, Lecture}
alias Kubuni.Enrollments.Enrollment
alias Kubuni.Payments.Payment
alias Kubuni.Accounts.User
alias Kubuni.Repo
alias Ecto.Changeset

admin_attrs = %{
  name: "Kubuni Admin",
  email: "admin@kubuni.test",
  phone: "254700000001",
  password: "password12345"
}

student_attrs = %{
  name: "One Student",
  email: "student@kubuni.test",
  phone: "254700000002",
  password: "student12345"
}

course_attrs = %{
  slug: "the-human-stack",
  title: "The Human Stack",
  subtitle: "Communication and Presentation Skills for Technology Professionals",
  description:
    "Learn to turn complex technical thinking into clear messages, persuasive presentations, and productive workplace conversations.",
  thumbnail_key: "/images/human-stack-course.svg",
  price_minor: 15_000_00,
  currency: "KES",
  status: :published,
  position: 1
}

modules = [
  {"Communication as a Technical Superpower",
   "Build the foundations for clear, intentional communication in technical environments.",
   [
     {"Why the human stack matters", 540},
     {"Diagnosing communication breakdowns", 660},
     {"Clarity, context, and intent", 720}
   ]},
  {"Know Your Audience and Message",
   "Shape a message around what your audience needs to understand, decide, or do.",
   [
     {"Reading the room", 600},
     {"From information to outcome", 780},
     {"The one-sentence message", 660}
   ]},
  {"Technical Storytelling",
   "Organise complex ideas into memorable narratives without losing accuracy.",
   [
     {"Story structure for technical ideas", 840},
     {"Explaining complexity with analogy", 720},
     {"Making evidence persuasive", 780}
   ]},
  {"Designing Clear Presentations",
   "Create slides and demonstrations that support your message instead of competing with it.",
   [
     {"One idea per slide", 720},
     {"Visual hierarchy and data", 840},
     {"Designing a coherent deck", 900}
   ]},
  {"Delivery, Presence, and Confidence",
   "Develop a grounded delivery style for rooms, calls, demos, and recorded presentations.",
   [
     {"Voice, pace, and pause", 660},
     {"Body language and virtual presence", 720},
     {"Practising for confidence", 780}
   ]},
  {"High-Stakes Workplace Communication",
   "Apply the human stack to feedback, difficult conversations, executive updates, and Q&A.",
   [
     {"Giving and receiving feedback", 840},
     {"Handling difficult conversations", 900},
     {"Executive updates and tough questions", 900}
   ]}
]

# Ready-made public HLS streams so seeded lectures actually play in development.
# The Kubuni.Media.Demo adapter (config/dev.exs) streams these URLs directly.
demo_streams = [
  "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
  "https://test-streams.mux.dev/tos_ismc/main.m3u8",
  "https://stream.mux.com/VZtzUzGRv02OhRnZCxcNg49OilvolTqdnFLEqBsTwLx7g.m3u8"
]

Repo.transaction(fn ->
  confirmed_at = DateTime.utc_now() |> DateTime.truncate(:second)

  case Repo.get_by(User, email: admin_attrs.email) do
    nil ->
      %User{}
      |> User.registration_changeset(admin_attrs)
      |> Changeset.put_change(:role, :admin)
      |> Changeset.put_change(:confirmed_at, confirmed_at)
      |> Repo.insert!()

    admin ->
      admin
      |> User.password_changeset(%{password: admin_attrs.password})
      |> Changeset.put_change(:name, admin_attrs.name)
      |> Changeset.put_change(:phone, admin_attrs.phone)
      |> Changeset.put_change(:role, :admin)
      |> Changeset.put_change(:confirmed_at, admin.confirmed_at || confirmed_at)
      |> Repo.update!()
  end

  student =
    case Repo.get_by(User, email: student_attrs.email) do
      nil ->
        %User{}
        |> User.registration_changeset(student_attrs)
        |> Changeset.put_change(:role, :learner)
        |> Changeset.put_change(:confirmed_at, confirmed_at)
        |> Repo.insert!()

      student ->
        student
        |> User.password_changeset(%{password: student_attrs.password})
        |> Changeset.put_change(:name, student_attrs.name)
        |> Changeset.put_change(:phone, student_attrs.phone)
        |> Changeset.put_change(:role, :learner)
        |> Changeset.put_change(:confirmed_at, student.confirmed_at || confirmed_at)
        |> Repo.update!()
    end

  course =
    case Repo.get_by(Course, slug: course_attrs.slug) do
      nil ->
        %Course{}
        |> Course.changeset(course_attrs)
        |> Repo.insert!()

      course ->
        course
        |> Course.changeset(course_attrs)
        |> Repo.update!()
    end

  Enum.with_index(modules, 1)
  |> Enum.each(fn {{title, description, lectures}, module_position} ->
    course_module =
      case Repo.get_by(CourseModule, course_id: course.id, position: module_position) do
        nil -> %CourseModule{}
        existing -> existing
      end
      |> CourseModule.changeset(%{
        course_id: course.id,
        title: title,
        description: description,
        position: module_position
      })
      |> then(fn changeset ->
        if changeset.data.id, do: Repo.update!(changeset), else: Repo.insert!(changeset)
      end)

    Enum.with_index(lectures, 1)
    |> Enum.each(fn {{lecture_title, duration_seconds}, lecture_position} ->
      stream_index = rem((module_position - 1) * 3 + (lecture_position - 1), length(demo_streams))

      case Repo.get_by(Lecture, module_id: course_module.id, position: lecture_position) do
        nil -> %Lecture{}
        existing -> existing
      end
      |> Lecture.changeset(%{
        module_id: course_module.id,
        title: lecture_title,
        description: "A focused lesson with practical examples and an application exercise.",
        video_provider: :mux,
        video_asset_id: Enum.at(demo_streams, stream_index),
        duration_seconds: duration_seconds,
        position: lecture_position
      })
      |> then(fn changeset ->
        if changeset.data.id, do: Repo.update!(changeset), else: Repo.insert!(changeset)
      end)
    end)
  end)

  enrollment =
    case Repo.get_by(Enrollment, user_id: student.id, course_id: course.id) do
      nil -> %Enrollment{}
      existing -> existing
    end
    |> Enrollment.changeset(%{
      user_id: student.id,
      course_id: course.id,
      status: :active,
      enrolled_at: confirmed_at,
      activated_at: confirmed_at
    })
    |> then(fn changeset ->
      if changeset.data.id, do: Repo.update!(changeset), else: Repo.insert!(changeset)
    end)

  payment_attrs = %{
    user_id: student.id,
    course_id: course.id,
    enrollment_id: enrollment.id,
    provider: :paystack,
    provider_reference: "KBI-SEED-PAID-STUDENT-HUMAN-STACK",
    amount_minor: course.price_minor,
    currency: course.currency,
    status: :successful,
    paid_at: confirmed_at,
    raw_payload: %{
      "seeded" => true,
      "status" => "success",
      "reference" => "KBI-SEED-PAID-STUDENT-HUMAN-STACK"
    }
  }

  case Repo.get_by(Payment, provider_reference: payment_attrs.provider_reference) do
    nil -> %Payment{}
    existing -> existing
  end
  |> Payment.changeset(payment_attrs)
  |> then(fn changeset ->
    if changeset.data.id, do: Repo.update!(changeset), else: Repo.insert!(changeset)
  end)
end)

IO.puts("Seeded admin account: #{admin_attrs.email} / #{admin_attrs.password}")
IO.puts("Seeded paid student account: #{student_attrs.email} / #{student_attrs.password}")
IO.puts("Seeded The Human Stack with 6 modules and 18 lectures.")
