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
alias Kubuni.Repo

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

Repo.transaction(fn ->
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
      case Repo.get_by(Lecture, module_id: course_module.id, position: lecture_position) do
        nil -> %Lecture{}
        existing -> existing
      end
      |> Lecture.changeset(%{
        module_id: course_module.id,
        title: lecture_title,
        description: "A focused lesson with practical examples and an application exercise.",
        video_provider: :mux,
        video_asset_id: "pending-human-stack-#{module_position}-#{lecture_position}",
        duration_seconds: duration_seconds,
        position: lecture_position
      })
      |> then(fn changeset ->
        if changeset.data.id, do: Repo.update!(changeset), else: Repo.insert!(changeset)
      end)
    end)
  end)
end)

IO.puts("Seeded The Human Stack with 6 modules and 18 lectures.")
