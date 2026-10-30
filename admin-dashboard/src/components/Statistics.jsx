import StatisticsCard from './StatisticsCard'

function Statistics() {
  return (
    <section>
      <h2>Dashboard Overview</h2>

      <StatisticsCard
        title="Total Orders"
        value={120}
      />

      <StatisticsCard
        title="Total Customers"
        value={85}
      />

      <StatisticsCard
        title="Available Foods"
        value={25}
      />
    </section>
  )
}

export default Statistics