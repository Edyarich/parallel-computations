#include <mpi.h>
#include <iostream>
#include <fstream>
#include <array>
#include <cassert>

const int MESG_SIZE = 2;
const int LEFT_LIMIT = 0;
const int RIGHT_LIMIT = 1;

const char OUT_FILENAME[] = "data.txt";

// const int SUBSEGMS_CNTS[] = {1'000, 1'000'000, 100'000'000};

double math_func(double x) {
    return 4.0 / (1.0 + x * x);
}

double calc_integral_sum(int left_border, const int right_border, const double delta) {
    double sum = 0.0;
    double x_start = left_border * delta;

    while (left_border < right_border) {
        sum += math_func(x_start + delta / 2.0);
        x_start += delta;
        ++left_border;
    }

    return sum * delta;
}

void send_borders(const int subsegms_cnt, const int proc_cnt) {
    int extra_blocks_cnt = subsegms_cnt - subsegms_cnt / proc_cnt * proc_cnt;
    int min_blocks_cnt = subsegms_cnt / proc_cnt;

    int p_left_border_ind = min_blocks_cnt + (extra_blocks_cnt > 0);

    for (int p_rank = 1; p_rank < proc_cnt; ++p_rank) {
        int blocks_cnt_for_p = min_blocks_cnt + (p_rank < extra_blocks_cnt);
        std::array<int, MESG_SIZE> p_mesg = {p_left_border_ind, blocks_cnt_for_p};

        MPI_Send(p_mesg.data(), p_mesg.size(), MPI_INT, p_rank, 0, MPI_COMM_WORLD);

        p_left_border_ind += blocks_cnt_for_p;
    }
}

void print_data(const double single_sum, const double multi_sum, const double single_time,
                                const double multi_time, const double* p_sums, const int proc_cnt) {
    std::cout << "--------------------------------------\n";
    std::cout << "Single Pi: " << single_sum << '\n';
    std::cout << "Multi Pi: " << multi_sum << '\n';
    for (int i = 0; i < proc_cnt; ++i) {
        std::cout << "Proc " << i << ", p_sum: " << p_sums[i] << '\n';
    }
    std::cout << "S: " << single_time / multi_time << '\n';
    std::cout << "--------------------------------------\n";
}

void open_file(std::fstream& file) {

}

void write_to_file(const int proc_cnt, const int subsegms_cnt, const double speedup) {
    std::fstream outfile;
    outfile.open(OUT_FILENAME, std::ios::out | std::ios::app);
    outfile << proc_cnt << ' ' << subsegms_cnt << ' ' << speedup << '\n';
    outfile.close();
}


int main(int argc, char** argv) {
    MPI_Init(&argc, &argv);

    assert(argc >= 2 && "Wrong argument's count");
    int subsegms_cnt = static_cast<int>(std::strtol(argv[1], nullptr, 10));

    int world_size;
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);

    int world_rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);

    const double delta = 1.0 * (RIGHT_LIMIT - LEFT_LIMIT) / subsegms_cnt;
    double single_sum = 0.0;
    double multi_sum = 0.0;
    double single_time = 0.0;
    double multi_time = 0.0;
    double p_sums[world_size];

    if (world_rank == 0) {
        double single_comp_start = MPI_Wtime();
        single_sum = calc_integral_sum(0, subsegms_cnt, delta);

        double single_comp_end = MPI_Wtime();
        single_time = single_comp_end - single_comp_start;
    }

    double multi_comp_start = MPI_Wtime();

    if (world_rank == 0) {
        int extra_blocks_cnt = subsegms_cnt - subsegms_cnt / world_size * world_size;
        int min_blocks_cnt = subsegms_cnt / world_size;

        send_borders(subsegms_cnt, world_size);

        multi_sum += calc_integral_sum(0, min_blocks_cnt + (extra_blocks_cnt > 0), delta);

    } else {
        int mesg[MESG_SIZE] = {};
        MPI_Recv(mesg, MESG_SIZE, MPI_INT, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);

        const int p_left_border_ind = mesg[0];
        const int p_blocks_cnt = mesg[1];
        const int p_right_border_ind = p_left_border_ind + p_blocks_cnt;
        double p_sum = calc_integral_sum(p_left_border_ind, p_right_border_ind, delta);

        MPI_Send(&p_sum, 1, MPI_DOUBLE, 0, 1, MPI_COMM_WORLD);
    }

    if (world_rank == 0) {
        p_sums[0] = multi_sum;

        for (int p_rank = 1; p_rank < world_size; ++p_rank) {
            MPI_Recv(&p_sums[p_rank], 1, MPI_DOUBLE, p_rank, 1, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            multi_sum += p_sums[p_rank];
        }

        double multi_comp_end = MPI_Wtime();
        multi_time = multi_comp_end - multi_comp_start;

        print_data(single_sum, multi_sum, single_time, multi_time, p_sums, world_size);
        write_to_file(world_size, subsegms_cnt, single_time / multi_time);
    }

    MPI_Finalize();
    return 0;
}
